//
//  SimpleHeaderView.swift
//  IESManager
//
//  Created by Richard Stockdale on 09/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import SwiftUI

struct SimpleHeaderView: View {

    let title: String

    var body: some View {
        VStack {
            Spacer()
            HStack{
                Text(title)
                    .bold()
            }
            Spacer()
            Divider()
        }
        .frame(height: 44)
    }
}

struct SimpleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleHeaderView(title: "This is a title")
    }
}
