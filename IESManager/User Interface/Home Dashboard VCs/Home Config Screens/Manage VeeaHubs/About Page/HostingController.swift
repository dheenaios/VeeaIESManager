//
//  HostingController.swift
//  IESManager
//
//  Created by Richard Stockdale on 09/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SwiftUI

public class HostWrapper: ObservableObject {
    public weak var controller:UIViewController?
}


/// Gives root SwiftUI view (and children) access the hosting controller by adding
/// @EnvironmentObject var host: HostWrapper
/// then e.g. host.controller?.dismiss()
public class HostingController<Content>:UIHostingController<ModifiedContent<Content,SwiftUI._EnvironmentKeyWritingModifier<HostWrapper?>>> where Content : View {

    public init(rootView:Content) {
        let container = HostWrapper()
        let modified = rootView.environmentObject(container) as! ModifiedContent<Content, _EnvironmentKeyWritingModifier<HostWrapper?>>
        super.init(rootView: modified)
        container.controller = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
