//
//  WdsListRows.swift
//  UI_Playground
//
//  Created by Richard Stockdale on 14/10/2022.
//

import SwiftUI

struct WdsListRows {
    static func horizontalKeyValueRow(key: String, value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
        }
    }

    static func verticalKeyValueRow(key: String,
                                    values: [String],
                                    checkMark: Bool = false) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4.0) {
                Text(key)
                    .font(.system(size: 17))
                ForEach(values, id: \.self) { value in
                    Text(value)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if checkMark {
                Image(systemName: "checkmark")
            }
        }
    }
}


// vm.nodes, id: \.self
