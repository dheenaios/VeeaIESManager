//
//  GroupBrowserViews.swift
//  IESManager
//
//  Created by Richard Stockdale on 13/06/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation
import SwiftUI
import SharedBackendNetworking

enum GroupSelectionType {
    case groupSelection, groupFavorite
}

struct CheckBox: View {
    var isChecked: Bool
    let action: (GroupSelectionType) -> Void

    var body: some View {
        ZStack {
            if isChecked {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
                Image(systemName: "checkmark")
                    .font(Font.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            else {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture { action(.groupSelection) }
    }
}

struct FavoriteToggle: View {
    var isFavorite: Bool
    let action: (GroupSelectionType) -> Void

    var body: some View {
        ZStack {
            if isFavorite {
                Image(systemName: "bookmark.fill")
                    .renderingMode(.template)
                    .foregroundColor(.orange)
            }
            else {
                Image(systemName: "bookmark")
            }
        }
        .onTapGesture { action(.groupFavorite) }
    }
}

struct GroupRow: View {
    internal init(model: GroupDisplayDetails,
                  selectedId: String,
                  checkedAction: @escaping (GroupSelectionType) -> Void) {
        self.model = model
        self.isChecked = model.groupId == selectedId
        self.checkedAction = checkedAction
    }

    private var model: GroupDisplayDetails
    private var isChecked: Bool
    private let checkedAction: (GroupSelectionType) -> Void

    var body: some View {
        HStack {
            CheckBox(isChecked: isChecked,
                     action: checkedAction)
                .padding(.horizontal, 8)
            VStack(alignment: .leading) {
                Text(model.groupName)
                    .font(Font(FontManager.bodyText))
                Text(model.groupDescription)
                    .font(Font(FontManager.infoText))
                    .if(!model.hasChildren) { text in
                        text.foregroundColor(Color(UIColor.lightGray))
                    }
                if let path = model.pathIfFav {
                    Text(path)
                        .foregroundColor(Color(UIColor.lightGray))
                        .font(Font(FontManager.regular(size: 12)))
                        .lineLimit(2)
                }
            }
            Spacer()
            FavoriteToggle(isFavorite: model.isFavorite,
                           action: checkedAction)
        }
        .padding(4)
    }
}

