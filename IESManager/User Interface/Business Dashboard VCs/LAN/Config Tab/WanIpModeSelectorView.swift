//
//  WanIpModeSelectorView.swift
//  IESManager
//
//  Created by Richard Stockdale on 19/07/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import SwiftUI

struct WanIpModeSelectorView: View {
    var wanModeText: String
    var ipModeText: String
    let ipModeSelectHidden: Bool
    let wanModeTapped: (() -> Void)
    let ipModeTapped: (() -> Void)

    private let buttonBgColor = UIColor(named: "LanPickerViewBackground") ?? .vGray
    private let borderColor: UIColor = .vGray

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                wanModeTapped()
            }) {
                modeButtonContents(title: "WAN MODE:",
                                   subTitle: wanModeText)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 16)

            if ipModeSelectHidden {
                Spacer()
            }
            else {
                Button(action: {
                    ipModeTapped()
                }) {
                    modeButtonContents(title: "IP MODE:",
                                       subTitle: ipModeText)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 16)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func modeButtonContents(title: String,
                                    subTitle: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
            Text(subTitle)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical)
        .background(Color(buttonBgColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(RoundedRectangle(cornerRadius: 10)
            .stroke(Color(borderColor), lineWidth: 1))
    }
}

struct WanIpModeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        WanIpModeSelectorView(wanModeText: "Isolated",
                              ipModeText: "Static",
                              ipModeSelectHidden: false,
                              wanModeTapped: {},
                              ipModeTapped: {})
    }
}
