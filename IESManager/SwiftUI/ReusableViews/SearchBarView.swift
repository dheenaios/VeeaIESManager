//
//  SearchBarView.swift
//  IESManager
//
//  Created by Richard Stockdale on 01/08/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import SwiftUI

// Could use .searchable when we get to iOS 15 as the min supported.

struct SearchBarView: View {
    @Binding var text: String
    let placeholderText: String
    var didChange: ((String?) -> Void)?
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            
            TextField(placeholderText, text: $text.onChange({ newString in
                didChange?(newString)
            }))
            .disableAutocorrection(true)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .onTapGesture {
                self.isEditing = true
            }
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)

                    if isEditing {
                        Button(action: {
                            self.text = ""
                            didChange?(nil)

                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 16)
                        }
                    }
                }
            )
            if isEditing {
                Button(action: {
                    cancelTapped()
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func cancelTapped() {
        self.isEditing = false
        self.text = ""
        didChange?(nil)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(text: .constant(""),
                      placeholderText: "Search Groups")
    }
}
