//
//  WalletImportView.swift
//  SIWE-Swift
//
//  Created by Daniel Bell on 2/18/22.
//

import SwiftUI
import web3swift
import LocalAuthentication

struct WalletImportView: View {
    @Binding public var ethWallet: WalletKeyStoreAccess?
    @Binding public var showView: Bool
    @StateObject private var viewModel = WalletImportViewModel()

    init(wallet: Binding<WalletKeyStoreAccess?>, showView show: Binding<Bool>) {
        #if os(iOS)
        UITextView.appearance().backgroundColor = .clear // First, remove the UITextView's backgroundColor.
        #endif
        _ethWallet = wallet
        _showView = show
    }

    var body: some View {
        VStack(alignment: .center, spacing: nil) {
            Text("Import Account")
                .padding(10)
                .foregroundColor(Color.secondaryOrange)
                .font(.system(size: 24.0, weight: .heavy))

            Spacer()
            VStack {
                Text("Seed Phrase/Private Key/ENS domain/Ethereum Address")
                    .importCard()
                    .foregroundColor(Color.secondaryOrange)
                if let errorMessage = viewModel.error {
                    Text(errorMessage)
                        .importCard()
                        .foregroundColor(Color.secondaryOrange)
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Import Type")
                        if let importTYpe = viewModel.source {
                            Text(importTYpe.rawValue)
                        }
                    }
                        .foregroundColor(Color.secondaryOrange)
                        .font(.system(size: 12, weight: .light))
                        .padding(.bottom, 2)
                    TextEditor(text: $viewModel.editText)
                        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 150, maxHeight: 150)
                        .background(Color.textBackground)
                        .foregroundColor(Color.textForeground)
                }
                .importCard()

                Spacer()

                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor( .primaryOrange)
                    .importCard()
            }
            .padding(.horizontal, 24)

            if viewModel.showPasswordEntry {
                WalletTextField(label: "Password", text: $viewModel.password1Text, validate: false)
                .importCard()
                .textContentType(.password)

                WalletTextField(label: "Confirm Password", text: $viewModel.password2Text, validate: false)
                .importCard()
                #if os(iOS)
                .textContentType(.newPassword)
                #endif
            }

            HStack {
                Text("sign in with face ID")
                    .foregroundColor(Color.secondaryOrange)
                    .font(.system(size: 16, weight: .heavy))
                Spacer()
                Toggle("Face ID", isOn: $viewModel.faceIsOn)
                    .tint(Color.primaryOrange)
                            .labelsHidden()
                            .onChange(of: viewModel.faceIsOn) { newValue in
                                guard newValue else { return }
                                let context = LAContext()
                                var error: NSError?

                                // check whether biometric authentication is possible
                                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                                    // it's possible, so go ahead and use it
                                    let reason = "We need to unlock your data."

                                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                                        // authentication has now completed
                                        if !success {
                                            // there was a problem
                                            DispatchQueue.main.async {
                                                viewModel.faceIsOn = false
                                            }
                                        }
                                    }
                                } else {
                                    // no biometrics
                                }
                            }
            }
            .importCard()

            Text("Terms")
                .foregroundColor(.red)
            Spacer()
            WalletButton(title: "Import") {
                Task {
                    ethWallet = await viewModel.importWallet()
                    if ethWallet != nil {
                        showView = false
                    }
                }
            }
            .padding(.bottom, 42)
        }
        .background(Color.background)
    }
}

struct ImportCardify: ViewModifier {
    var minBorder: Bool = false
    func body(content: Content) -> some View {
        HStack(alignment: .center) {
            content
        }
        .padding(.horizontal, minBorder ? 10 : 16)
        .padding(.vertical, minBorder ? 6 : 12)
        .cornerRadius(16)
        .background(Color.black.cornerRadius(16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 24/255, green: 30/255, blue: 37/255), lineWidth: 2)
        )
    }
}

extension View {
    func importCard() -> some View {
        modifier(ImportCardify())
    }
    func importCardMinBorder() -> some View {
        modifier(ImportCardify(minBorder: true))
    }
}

struct WalletTextField: View {
    var label: String
    @Binding var text: String
    var validate: Bool
    @State private var isSecured: Bool = true
    @State private var passwordError: String?

    func validate(password: String) {

        guard !password.isEmpty else {
            passwordError = nil
            return
        }

        //At least 8 characters
        if password.count < 8 {
            passwordError = "Must Be Min Length 8"
            return
        }

        //At least one digit
        if password.range(of: #".*[0-9]+.*"#, options: .regularExpression) == nil {
            passwordError = "Must Contain At Least 1 digit"
            return
        }

        //At least one letter
        if password.range(of: #".*[a-zA-Z]+.*"#, options: .regularExpression) == nil {
            passwordError = "Must Contain At Least 1 Letter"
            return
        }

        //At least one special Character
        if password.range(of: #".*[!&^%$#@()._-]+.*"#, options: .regularExpression) == nil {
            passwordError = "Must Contain At Least 1 of !&^%$#@()._-"
            return
        }

        //No whitespace charcters
        if password.range(of: #"\s+"#, options: .regularExpression) != nil {
            passwordError = "Must Not Contain Spaces"
            return
        }

        passwordError = nil
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: nil) {
                HStack {
                    Text(label)
                        .foregroundColor(Color.labelForeground)
                        .font(.system(size: 12, weight: .light))
                        .padding(.bottom, 2)
                    Spacer()
                    if let passwordError = passwordError {
                        Text(passwordError)
                    }
                }
                Group {
                    if isSecured {
                        SecureField("Password", text: $text)
                    } else {
                        TextField("Password", text: $text)
                            .onChange(of: text) { newValue in
                                if validate {
                                    validate(password: newValue)
                                }
                            }
                            .onSubmit {
                                if validate {
                                    validate(password: text)
                                }
                            }
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .disableAutocorrection(true)
                    }
                }
                    .padding()
                    .background(Color.textBackground)
                    .foregroundColor(Color.textForeground)
            }
            Image(systemName: isSecured ? "eye.slash" : "eye")
                .foregroundColor(.gray)
                .onTapGesture {
                    isSecured.toggle()
                }
        }
    }
}
