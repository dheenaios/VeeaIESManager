//
//  SwiftUIUIView.swift
//  IESManager
//
//  Created by Richard Stockdale on 30/09/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SwiftUI

public struct SwiftUIUIView<V: SwiftUI.View> {
    public var hostingViewController: UIHostingController<V>
    private let requireSelfSizing: Bool
    
    public func make() -> UIView {
            if requireSelfSizing {
                let result = SwiftUIContainerView(hostingController: hostingViewController)
                hostingViewController.didMove(toParent: nil)
                return result
            } else {
                hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false
                hostingViewController.didMove(toParent: nil)
                return hostingViewController.view
            }
        }
    
    init(view: any View, requireSelfSizing: Bool = false) {
        self.hostingViewController = UIHostingController(rootView: view as! V)
        self.requireSelfSizing = requireSelfSizing
    }
    
    private class SwiftUIContainerView<V: SwiftUI.View>: UIView, UIHostingControllerContainer {

        init(hostingController: UIHostingController<V>) {
            self.hostingController = hostingController
            super.init(frame: .zero)

            hostingController.view.translatesAutoresizingMaskIntoConstraints = true
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostingController.view.backgroundColor = .clear
            addSubview(hostingController.view)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private weak var hostingController: UIHostingController<V>?

        override func sizeThatFits(_ size: CGSize) -> CGSize {
            if let hostingController = hostingController {
                return hostingController.sizeThatFits(in: size)
            } else {
                return super.sizeThatFits(size)
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            let size = self.sizeThatFits(bounds.size)
            hostingController?.view.frame.size = size
        }
    }
}

private protocol UIHostingControllerContainer {
    func sizeThatFits(_ size: CGSize) -> CGSize
}
