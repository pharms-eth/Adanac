//
//  WalletCreatePasswordView.swift
//  Adanac
//
//  Created by Daniel Bell on 3/5/22.
//

import SwiftUI
import LocalAuthentication

struct WalletCreatePasswordView: View {
    @ObservedObject var model: WalletCreateViewModel

    @State var seedAckInError = false
    @State var passwordInError = false
    @Binding var showPasswordEntry: Bool

    var body: some View {
        VStack(alignment: .center, spacing: nil) {
            VStack(alignment: .center, spacing: nil) {
                VStack(spacing: 8.0) {
                    Text("Password")
                        .font(.system(size: 16.0, weight: .bold))
                        .foregroundColor(.primaryOrange)
                    Text("This password will unlock your wallet only on this service")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondaryOrange)
                }
                .padding(.vertical, 40)

                if showPasswordEntry {
                    WalletTextField(label: "Password", text: $model.password1, validate: true)
                    .importCard()
                    .textContentType(.password)

                    WalletTextField(label: "Confirm Password", text: $model.password2, validate: true)
                    .importCard()
                    #if os(iOS)
                    .textContentType(.newPassword)
                    #endif
                    .border(Color.primaryOrange, width: passwordInError ? 3 : 0)
                }

                HStack {
                    Text("sign in with face ID")
                        .foregroundColor(Color.secondaryOrange)
                        .font(.system(size: 16, weight: .heavy))
                    Spacer()
                    Toggle("Face ID", isOn: $model.faceIDOn)
                        .tint(Color.primaryOrange)
                                .labelsHidden()
                                .onChange(of: model.faceIDOn) { newValue in
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
                                                    model.faceIDOn = false
                                                }
                                            }
                                        }
                                    } else {
                                        // no biometrics
                                    }
                                }
                }
                .importCard()
//                HStack {
//                    Text("save account to icloud")
//                        .foregroundColor(Color.secondaryOrange)
//                        .font(.system(size: 16, weight: .heavy))
//                    Spacer()
//                    Toggle("iCLoud", isOn: $model.iCloudOn)
//                        .tint(Color.primaryOrange)
//                                .labelsHidden()
//                }
//                .importCard()

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
                model.setPhase(.seedRetrieve)
            }
            .padding(.bottom, 42)
        }
        .background(Color.background)
    }
}

// struct WalletCreatePasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletCreatePasswordView(password1: .constant(""), password2: .constant("Password"), passwordOn: .constant(true), progress: .constant(.start), phase: .constant(.password))
//    }
// }
