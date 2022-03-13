//
//  WalletImportView.swift
//  SIWE-Swift
//
//  Created by Daniel Bell on 2/18/22.
//

import SwiftUI

struct WalletImportView: View {
    @Binding public var ethWallet: Wallet?
    @Binding public var showView: Bool
    @StateObject private var viewModel = WalletImportViewModel()


    init(wallet: Binding<Wallet?>, showView show: Binding<Bool>) {
        UITextView.appearance().backgroundColor = .clear // First, remove the UITextView's backgroundColor.
        _ethWallet = wallet
        _showView = show
    }

    var body: some View {
        VStack(alignment: .center) {
            Text("Import Account")
                .padding(10)
                .foregroundColor(Color.secondaryOrange)
                .font(.system(size: 24.0, weight: .heavy))

            Spacer()
            Text("Seed Phrase/Private Key/ENS domain/Ethereum Address")
                .importCard()
                .foregroundColor(Color.secondaryOrange)
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

            WalletTextField(label: "Password", text: $viewModel.password1Text)
            .importCard()

            WalletTextField(label: "Confirm Password", text: $viewModel.password2Text)
            .importCard()

            HStack {
                Text("sign in with face ID")
                    .foregroundColor(Color.secondaryOrange)
                    .font(.system(size: 16, weight: .heavy))
                Spacer()
                Toggle("Face ID", isOn: $viewModel.faceIsOn)
                    .tint(Color.primaryOrange)
                            .labelsHidden()
            }
            .importCard()

            Text("Terms")
                .foregroundColor(.red)
            Spacer()
            WalletButton(title: "Import") {
//                Task {
//                    ethWallet = await viewModel.importWallet()
//                }
                showView = false
            }
            .padding(.bottom, 42)
        }
        .background(Color.background)
    }
}

struct ImportCardify: ViewModifier {
    func body(content: Content) -> some View {
        HStack(alignment: .center) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
}

struct WalletTextField: View {
    var label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment:.leading) {
            Text(label)
                .foregroundColor(Color.labelForeground)
                .font(.system(size: 12, weight: .light))
                .padding(.bottom, 2)
            TextField("Password", text: $text)
                .padding()
                .background(Color.textBackground)
                .foregroundColor(Color.textForeground)
        }
    }
}


