//
//  ActionButton.swift
//  IESManager
//
//  Created by Richard Stockdale on 09/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import SwiftUI

struct ActionButton: View {

    let title: String
    let bgColor: DynamicColor
    var textColor: DynamicColor = InterfaceManager.shared.cm.textWhite
    let font = FontManager.bigButtonText
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 0,
                       idealWidth: .infinity,
                       maxWidth: .infinity,
                       minHeight: 0,
                       idealHeight: 44, maxHeight: 44)
        }
        .foregroundColor(Color(textColor.colorForAppearance))
        .background(Color(bgColor.colorForAppearance))
        .cornerRadius(8)
        .font(Font(font))
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(title: "Button",
                     bgColor: InterfaceManager.shared.cm.themeTint) {}
    }
}

struct ClearBorderedActionButton: View {

    let title: String
    var textBorderColor: DynamicColor = InterfaceManager.shared.cm.themeTint
    var backgroundColor: DynamicColor = InterfaceManager.shared.cm.textWhite
    let font = FontManager.bigButtonText
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 0,
                       idealWidth: .infinity,
                       maxWidth: .infinity,
                       minHeight: 0,
                       idealHeight: 44, maxHeight: 44)
        }
        .foregroundColor(Color(textBorderColor.colorForAppearance))
        .background(Color(backgroundColor.colorForAppearance))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color(textBorderColor.colorForAppearance), lineWidth: 4))
        .cornerRadius(8)
        .font(Font(font))
    }
}
