//
//  CloseButton.swift
//  IESManager
//
//  Created by Richard Stockdale on 25/04/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import SwiftUI

struct CloseButton: View {
    internal init(inUIView: Bool = false, action: @escaping () -> Void) {
        self.action = action
        if inUIView {
            self.inUIView = inUIView
        }
        else if #available(iOS 15.0, *) {
            self.inUIView = inUIView
        }
        else { // If iOS Version 13 or 14, the view spacing behaves differently
            self.inUIView = true
        }
    }

    let inUIView: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                if inUIView { Spacer() }
                Image(systemName: "xmark")
                    .font(Font.system(size: 12, weight: .bold))
                    .foregroundColor(Color(UIColor.gray))
                Spacer()
            }
            .padding(.all, 0)
        }
        .frame(width: 30, height: 30)
        .background(Color(UIColor.vGray))
        .clipShape(Circle())
    }


}
