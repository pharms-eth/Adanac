//
//  Buttons.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import SwiftUI

struct WalletSetupStyledButton: View {//<Content: View>: View {

    @Binding public var showingPopover: Bool
    var title: String
    var background: Color
//    var content: () -> Content

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: 16.0, weight: .bold))
            Spacer()
        }
            .padding(16)
            .foregroundColor(.white)
            .background(background)
            .cornerRadius(168)
            .onTapGesture {
                showingPopover.toggle()
            }
//            .popover(isPresented: $showingPopover) {
//                content()
//            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
    }
}

struct WalletButton: View {
    var title: String
    var background: Color = .primaryOrange
//    Color(red: 228/255, green: 86/255, blue: 4/255)
    var action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: 16.0, weight: .bold))
            Spacer()
        }
            .padding(16)
            .foregroundColor(.white)
            .background(background)
            .cornerRadius(168)
            .onTapGesture {
                action()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
  @Environment(\.isEnabled) var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle() // toggle the state binding
    } label: {
      HStack {
        Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
          .imageScale(.large)
        configuration.label
      }
    }
    .buttonStyle(PlainButtonStyle()) // remove any implicit styling from the button
    .disabled(!isEnabled)
  }
}
