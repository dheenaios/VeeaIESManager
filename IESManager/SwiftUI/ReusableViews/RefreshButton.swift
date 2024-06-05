//
//  RefreshButton.swift
//  IESManager
//
//  Created by Dheena on 11/03/24.
//  Copyright © 2024 Veea. All rights reserved.
//

import SwiftUI

struct RefreshButton: View {
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
                Image(systemName: "arrow.clockwise")
                    .font(Font.system(size: 16, weight: .bold))
                    .foregroundColor(Color(UIColor.systemBlue))
                Spacer()
            }
            .padding(.all, 0)
        }
        .frame(width: 30, height: 30)
        .background(Color(UIColor.clear))
        .clipShape(Circle())
    }


}
