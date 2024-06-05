//
//  SwiftUIView.swift
//  IESManager
//
//  Created by Richard Stockdale on 05/07/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import SwiftUI

/*
 Created to replace the existing cell. Works well with iOS 16.
 iOS 15 and below showed some issues, with the view drifting. Will replace with UIKit implementation
 Keeping this around as a possible replacement for the UIKit version.

 See VHMeshTableCell
 JIRA URL: https://max2inc.atlassian.net/browse/VHM-1651

 */

struct MeshTableCellView: View {
    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {
        HStack {
            Image(imageName)
                .imageScale(.large)
            VStack {
                HStack {
                    Text(title)
                        .font(Font(FontManager.bold(size: 18)))
                    Spacer()
                }
                HStack {
                    Text(subtitle)
                        .font(Font(FontManager.regular(size: 14)))
                    Spacer()
                }
            }

            Spacer()

        }
        .padding()
    }
}

struct MeshTableCellView_Previews: PreviewProvider {
    static var previews: some View {
        MeshTableCellView(title: "Title",
                          subtitle: "Subtitle",
                          imageName: "mesh_black_small")
    }
}
