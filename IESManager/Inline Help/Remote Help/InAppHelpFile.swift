//
//  HelpFiles.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 25/10/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

enum InAppHelpFile: String {
    case services,
         about_veeaHub,
         bt_beacon,
         cellular_stats,
         firewall,
         ip_address,
         lan_configuration,
         lan_dhcp,
         lan_reserved_ips,
         physical_ports_tips,
         physical_ports,
         router,
         vmesh_help_men,
         vmesh_help_mn,
         wan_configuration,
         wan_interfaces,
         wan_reserved_ips,
         wifi_aps,
         wifi_radios
    
    func getMdText() -> String? {
        // Get the loaded text first
        if let content = loadFromUrl(url: remoteUrl) {
            return content
        }
        
        // If not get local
        if let content = loadLocalMd() {
            return content
        }
        
        return nil
    }
    
    private var baseUrl: String {
        if BackEndEnvironment.internalBuild {
            return "https://vhm-help-pages-internal.s3.amazonaws.com/"
        }
        
        return "https://vhm-help-pages.s3.amazonaws.com/"
    }
    
    private var remoteUrl: URL {
        let urlString = "\(baseUrl)\(self.rawValue).md"
        return URL(string: urlString)!
    }
    
    func loadFromUrl(url: URL) -> String? {
        do {
            let contents = try String(contentsOf: url)
            return updateLinksForRemoteEnvironment(mdString: contents)
        }
        catch { return nil }
    }
    
    func loadLocalMd() -> String? {
        if let filepath = Bundle.main.path(forResource: self.rawValue, ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            }
            catch { return nil}
        }
        
        return nil
    }
}

// MARK: - Link updating
extension InAppHelpFile {
    private func updateLinksForRemoteEnvironment(mdString: String) -> String {
        let imgRegex = #"!\[[^\]]*\]\((.*?)\s*("(?:.*[^"])")?\s*\)"#
        let regex = try! NSRegularExpression(pattern: imgRegex)
        let range = NSRange(mdString.startIndex..., in: mdString)
        let results = regex.matches(in: mdString, range: range)
        
        // Get the matched strings
        let resultsArray = results.map {
            String(mdString[Range($0.range, in: mdString)!])
        }
        
        var modifiedString = mdString
        
        for result in resultsArray {
            if let modifiedImgRef = updateFoundStrings(foundString: result) {
                modifiedString = modifiedString.replacingOccurrences(of: result,
                                                                     with: modifiedImgRef)
            }
        }
        
        return modifiedString
    }
    
    private func updateFoundStrings(foundString: String) -> String? {
        let splitString = foundString.components(separatedBy: "(")
        if splitString.count == 2 {
            let fileName = splitString[1].dropLast()
            let updated = foundString.replacingOccurrences(of: fileName, with: "\(baseUrl)\(fileName)")
            
            return updated
        }
        
        return nil
    }
}
