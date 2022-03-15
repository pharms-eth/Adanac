//
//  WalletCreatePasswordView.swift
//  Adanac
//
//  Created by Daniel Bell on 3/5/22.
//

import SwiftUI

struct WalletCreatePasswordView: View {
    @ObservedObject var model: WalletCreateViewModel

    @State var seedAckInError = false
    @State var passwordInError = false

    var body: some View {
        VStack {

            VStack {
                VStack(spacing: 8.0) {
                    Text("Password")
                        .font(.system(size: 16.0, weight: .bold))
                        .foregroundColor(.primaryOrange)
                    Text("This password will unlock your wallet only on this service")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondaryOrange)
                }
                .padding(.vertical, 40)

                WalletTextField(label: "Password", text: $model.password1)
                .importCard()

                WalletTextField(label: "Confirm Password", text: $model.password2)
                .importCard()
                .border(Color.primaryOrange, width: passwordInError ? 3 : 0)

                HStack {
                    Text("sign in with face ID")
                        .foregroundColor(Color.secondaryOrange)
                        .font(.system(size: 16, weight: .heavy))
                    Spacer()
                    Toggle("Face ID", isOn: $model.passwordOn)
                        .tint(Color.primaryOrange)
                                .labelsHidden()
                }
                .importCard()
                HStack {
                    Text("save account to icloud")
                        .foregroundColor(Color.secondaryOrange)
                        .font(.system(size: 16, weight: .heavy))
                    Spacer()
                    Toggle("Face ID", isOn: $model.passwordOn)
                        .tint(Color.primaryOrange)
                                .labelsHidden()
                }
                .importCard()

                HStack {
                    Toggle("I understand that this password cannot be recovered for me. Learn more", isOn: $model.seedAck)
                        .toggleStyle(CheckboxToggleStyle())
                        .foregroundColor(.red)
                }
                .foregroundColor(.primaryOrange)
                .padding(seedAckInError ? 8 : 0)
                .border(Color.primaryOrange, width: seedAckInError ? 3 : 0)

            }
            .padding(.horizontal)
            Spacer()
            WalletButton(title: "Set Password") {
                guard model.seedAck else {
                    seedAckInError = true
                    return
                }
                seedAckInError = false
                guard model.password1 == model.password2, !model.password1.isEmpty else {
                    passwordInError = true
                    return
                }
                passwordInError = false
                Task {
                    await model.setPhase(.seedRetrieve)
                }
            }
            .padding(.bottom, 42)
        }
        .background(Color.background)
    }
}


//struct WalletCreatePasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletCreatePasswordView(password1: .constant(""), password2: .constant("Password"), passwordOn: .constant(true), progress: .constant(.start), phase: .constant(.password))
//    }
//}
