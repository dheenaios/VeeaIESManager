//
//  SwiftUIVersionModifers.swift
//  IESManager
//
//  Created by Richard Stockdale on 14/10/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import SwiftUI

extension View {
    // Style list as a simple list
    func simpleListStyle() -> some View {
        modifier(SimpleListStyleModifer())
    }

    func navBarTitle(_ title: String) -> some View {
        modifier(NavBarTitle(title: title))
    }
}

// Modifier to display the table as well as possible given the os level
struct SimpleListStyleModifer: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .listStyle(.grouped)
                .scrollContentBackground(.hidden)
        }
        else {
            content
                .listStyle(.inset)
        }
    }
}

struct NavBarTitle: ViewModifier {

    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
    }
}
