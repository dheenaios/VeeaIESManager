//
//  NamingDialogView.swift
//  IESManager
//
//  Created by Dheena on 13/11/23.
//  Copyright © 2023 Veea. All rights reserved.
//

import SwiftUI

struct NamingDialogView: View {
    private let title: String
    private let message: String

    private let leftButtonTitle: String
    private let rightButtonTitle: String
    private let rightButtonIsDescructive: Bool

    @State var validationMessage: String
    @State var textFieldText: String
    @State var isFirstResponder = true
    
    /// Bool is true if user accepts/ False if the cancel
    /// String is the entered text
    private var buttonAction: ((Bool, String) -> ())
    
    init(title: String,
         message: String,
         leftButtonTitle: String = "Cancel",
         rightButtonTitle: String = "OK".localized(),
         rightButtonIsDescructive: Bool = true,
         validationMessage: String = "",
         textFieldText: String,
         buttonAction: @escaping (Bool, String) -> Void) {
        self.title = title
        self.message = message
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.rightButtonIsDescructive = rightButtonIsDescructive
        self.validationMessage = validationMessage
        self.textFieldText = textFieldText
        self.buttonAction = buttonAction
    }

    var body: some View {
        ZStack {

            // faded background
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            VStack {

                // Add some space to the top
                VStack(){ EmptyView()
                }
                .frame(width: 260, height: 80)

                VStack(spacing: 0) {
                    titleMessageView()
                    textAndValidationView()
                    buttonsView()
                }
                .frame(width: 270,
                       height: 270,
                       alignment: .center)
                .background(
                    Color.white
                )
                .cornerRadius(8)

                Spacer()
            }
        }
                .edgesIgnoringSafeArea(.all)
                .animation(.easeOut(duration: 0.16))
    }

    private func titleMessageView() -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(height: 40)
                .padding(.top, 14)
                .padding(.bottom, 6)


            Text(message)
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(height: 48)
                .padding(.bottom, 6)
                .minimumScaleFactor(0.5)
        }
        .padding(.horizontal, 16)
    }

    private func textAndValidationView() -> some View {
        VStack(spacing: 4) {
            LegacyTextField(text: $textFieldText.onChangeValue({ value in
                let message = NameValidation.meshNameHasErrors(name: value) ?? ""
                validationMessage = message
            }),
                            isFirstResponder: $isFirstResponder)
            .frame(height: 30)
            
            
            HStack {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .lineLimit(4)
                    .padding(.vertical, 2)
                Spacer()
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    private func buttonsView() -> some View {
        VStack(spacing: 0) {
            Divider()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
                .padding(.all, 0)

            HStack(spacing: 0) {
                Button {
                    buttonAction(false, textFieldText)
                } label: {
                    Text(leftButtonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(minWidth: 0,
                               maxWidth: .infinity,
                               minHeight: 0,
                               maxHeight: .infinity)
                }
                Divider()
                    .frame(minWidth: 0, maxWidth: 0.5, minHeight: 0, maxHeight: .infinity)

                Button {
                    if validationMessage.isEmpty { buttonAction(true, textFieldText) }
                } label: {
                    Text(rightButtonTitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(renameButtonColor)
                        .multilineTextAlignment(.center)
                        .padding(15)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
            }
        }
        .frame(height: 48)
    }

    var renameButtonColor: Color {
        if !validationMessage.isEmpty {
            return .gray
        }

        return rightButtonIsDescructive ? .red : .blue
    }
}

extension Binding {
    func onChangeValue(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}


