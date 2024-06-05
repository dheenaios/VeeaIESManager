///
//  SendingView.swift
//  UI_Playground
//
//  Created by Richard Stockdale on 19/10/2022.
//

import SwiftUI

struct SendingView: View {
    var body: some View {
        ZStack {
            VStack{
                Spacer()
                capsule
                    .frame(width: 300, height: 40)
                    .shadow(radius: 5)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .disabled(true)
            .onTapGesture {
                // DO NOTHING. JUST INTERCEPT
            }

        }

    }

    var capsule: some View {
        VStack {
            Capsule()
                .fill(.background)
                .overlay(
                    contentView
                )
        }
    }

    var contentView: some View {
        HStack {
            ProgressView()
            Text("     \("Updating VeeaHub...".localized())")
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SendingView()
    }
}
