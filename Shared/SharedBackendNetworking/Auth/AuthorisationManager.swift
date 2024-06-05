//
//  AuthorisationManager.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

import Foundation
import AppAuth
import KeychainSwift
import JWTDecode

public protocol AuthFlowSessionManagerProtocol: AnyObject {
    var currentAuthorizationFlow: OIDExternalUserAgentSession? { get set }
}

public protocol AuthorisationDelegate: AnyObject {

    /// Called on completion of the discovery process.
    /// - Parameter success: Bool for success. String for any error message
    func configDiscoveryCompleted(success: (SuccessAndOptionalMessage))


    /// The result of a login request
    /// - Parameter success: Bool for success. String for any error message
    func loginRequestResult(success: (SuccessAndOptionalMessage))


    /// Results of OpenID info request call
    /// - Parameter success: Bool for success. String for any error message
    func gotUserInfoResult(success: (Bool, String?, VHUser?))
}

public class AuthorisationManager: NSObject {

    private let kUserDetails = "UserDetails"

    public static var shared = AuthorisationManager()

    private var _lastUser: VHUser?
    var lastUser: VHUser? {
        get {
            // Is it in memory
            if let _lastUser = _lastUser {
                return _lastUser
            }

            // Is it in user defaults
            let d = SharedUserDefaults.suite
            if let userDetails = d.object(forKey: kUserDetails) as? Data {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode(VHUser.self, from: userDetails) {
                    _lastUser = decoded
                }
            }
            
            // Check CURRENT_VHUSER.
            // Remove this in the future as this location should no longer be in use
            if let userDetails = d.value(forKey: "CURRENT_VHUSER") as? Data {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode(VHUser.self, from: userDetails) {
                    _lastUser = decoded
                }
            }

            return _lastUser
        }
        set {
            if newValue == _lastUser {
                return
            }
            
            let d = SharedUserDefaults.suite
            guard let newValue = newValue else {
                d.removeObject(forKey: kUserDetails)
                _lastUser = nil
                return
            }

            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                d.set(encoded, forKey: kUserDetails)
            }

            _lastUser = newValue
        }
    }

    public var isLoggedIn: Bool {
        formattedAuthToken != nil
    }

    public var delegate: AuthorisationDelegate?

    internal var authState: OIDAuthState?
    
    internal lazy var keychain: KeychainSwift = {
        let accessGroup = ApplicationTargets.current.keychainGroup
        let kchain = KeychainSwift()
        kchain.accessGroup = accessGroup

        return kchain
    }()
    internal let authStateKey = "kAuthStateKey"

    // MARK: - END POINT AND CLIENT DETAILS

    private let clientID = "vhm"
    private static let redirectURI = "com.virtuosys.iesmanager:/oauth2redirect"

    private static var realm: String {
        return BackEndEnvironment.authRealm + VeeaRealmsManager.selectedRealm
    }

    private var issuer = URL(string: AuthorisationManager.realm)!

    internal var userInfoEndPoint = URL(string: "\(AuthorisationManager.realm)/protocol/openid-connect/userinfo")!

    private var resetUserPasswordUrl = URL(string: "\(AuthorisationManager.realm)/login-actions/reset-credentials?client_id=account")!

    internal var logoutUrl = URL(string: "\(AuthorisationManager.realm)/protocol/openid-connect/logout")!

    public var changePasswordUrl = URL(string: "\(AuthorisationManager.realm)/account/password")!

    // TODO: REMOVE THIS WHEN WE MOVE AWAY FROM DEV SERVER. USED TO GET AROUND THE TEST SERVER ISSUES
    // SEE THE URLSessionDelegate EXTENSION
    internal var debugSession: URLSession?

    public func reset() {
        issuer = URL(string: AuthorisationManager.realm)!
        userInfoEndPoint = URL(string: "\(AuthorisationManager.realm)/protocol/openid-connect/userinfo")!
        resetUserPasswordUrl = URL(string: "\(AuthorisationManager.realm)/login-actions/reset-credentials?client_id=account")!
        logoutUrl = URL(string: "\(AuthorisationManager.realm)/protocol/openid-connect/logout")!
        changePasswordUrl = URL(string: "\(AuthorisationManager.realm)/account/password")!
    }

    // MARK: - INIT AND INTIAL DISCOVERY
    public var userIdLegacy: Int {
        guard let jwt else { return -1 }
        if let id = jwt.userId { return id }

        return -1
    }

    /// Keycloak user id
    public var userId: String? { return jwt?.sub }

    private var jwt: JWT? {
        guard let tokenString = authState?.lastTokenResponse?.accessToken else { return nil }
        do {
            let jwt = try decode(jwt: tokenString)
            return jwt
        }
        catch {
            return nil
        }
    }

    // The discovered configuration
    private var discoveredConfiguration: OIDServiceConfiguration?

    public override init() {
        super.init()
        setup()
    }

    public func setup() {
        debugSession = URLSession(configuration: .default,
                                  delegate: self,
                                  delegateQueue: OperationQueue.main)

        OIDURLSessionProvider.setSession(debugSession!)

        // Load any existing auth statue
        if let existingAuth = loadAuthState() {
            authState = existingAuth
        }
    }
}

// MARK: - INITIAL REQUEST
extension AuthorisationManager {
    /// 1. Discover configuration
    public func discoverConfiguration() {
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            guard let config = configuration else {
                let message = "\("Error retrieving discovery document"): \(error?.localizedDescription ?? "Unknown error")"
                self.delegate?.configDiscoveryCompleted(success: (false, message))

                return
            }

            self.discoveredConfiguration = config
            self.delegate?.configDiscoveryCompleted(success: (true, nil))
        }
    }

    /// 2. Make login request. Result reported via the delegate
    /// - Parameter hostViewController: The host view controller that will display the login Safari View Controller
    public func requestLogin(hostViewController: UIViewController,
                             authFlowSessionManager: AuthFlowSessionManagerProtocol) {
        guard let config = discoveredConfiguration else {
            delegate?.loginRequestResult(success: (false, "No discovered config."))

            return
        }

        doAccessTokenRequest(configuration: config,
                             hostViewController: hostViewController,
                             authFlowSessionManager: authFlowSessionManager)
    }

    private func doAccessTokenRequest(configuration: OIDServiceConfiguration,
                                      hostViewController: UIViewController,
                                      authFlowSessionManager: AuthFlowSessionManagerProtocol) {
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, "offline_access"],
                                              redirectURL: URL(string: AuthorisationManager.redirectURI)!,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["prompt" : "login"])

        // performs authentication request
        //print("Initiating authorization request with scope: \(request.scope ?? "nil")")

        authFlowSessionManager.currentAuthorizationFlow =
        OIDAuthState.authState(byPresenting: request,
                               presenting: hostViewController) { authState, error in
            if let authState = authState {
                self.authState = authState
                self.saveAuthState()

                //print("Got authorization tokens. Access token: " +
                 //     "\(authState.lastTokenResponse?.accessToken ?? "nil")")

                self.delegate?.loginRequestResult(success: (true, nil))
            }
            else {
                self.authState = nil
                self.saveAuthState()
            }
        }
    }

    internal func refreshTokenAndUserInfo(completed: @escaping (Bool) -> Void) {
        authState?.setNeedsTokenRefresh()
        getUserInfo(completed: completed)
    }

    internal func refreshTokenAndUserInfo() async -> Bool {
        authState?.setNeedsTokenRefresh()
        return await getUserInfo()
    }
}

extension AuthorisationManager: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:challenge.protectionSpace.serverTrust!))
    }
}

// MARK: - Persistance
extension AuthorisationManager {
    func saveAuthState() {
        do {
            let authStateData = try NSKeyedArchiver.archivedData(withRootObject: authState as Any, requiringSecureCoding: false)
            keychain.set(authStateData, forKey: authStateKey)
        }
        catch {
            //Logger.log(tag: "AuthorisationManager", message: "Failed to save authState")
        }
    }

    func deleteAuthState() {
        keychain.delete(authStateKey)
    }

    /// Load auth state from the keychain
    func loadAuthState() -> OIDAuthState? {
        guard let authStateData = keychain.getData(authStateKey) else {
            return nil
        }

        do {
            if let authStateObj = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(authStateData) as? OIDAuthState {
                return authStateObj
            }
        }
        catch {
            //Logger.log(tag: "AuthorisationManager", message: "Failed to load authState")
        }

        return nil
    }
}
