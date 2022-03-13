//
//  EllipticalProgress.swift
//  Adanac
//
//  Created by Daniel Bell on 3/5/22.
//

import SwiftUI

struct EllipticalProgress: View {
    enum Progress {
        case start
        case mid
        case end
    }
    @Binding var progress: Progress

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Rectangle()
                    .fill( Color.secondaryOrange )
                    .frame(height: 1)
                    .overlay(
                        Rectangle()
                            .fill(Color.primaryOrange)
                            .scaleEffect((progress == .mid || progress == .end) ? 1 : 0 , anchor: .leading)
                            .animation(.linear(duration: 1.0), value: progress)
                    )

                Rectangle()
                    .fill( Color.secondaryOrange )
                    .frame(height: 1)
                    .overlay(
                        Rectangle()
                            .fill(Color.primaryOrange)
                            .scaleEffect((progress == .end) ? 1 : 0 , anchor: .leading)
                            .animation(.linear(duration: 1.0), value: progress)
                    )
            }
            HStack {
                Circle()
                    .fill(Color.primaryOrange)
                    .frame(width: 8, height: 8)
                Spacer()
                Circle()
                    .fill(progress != .start ? Color.primaryOrange : Color.secondaryOrange)
                    .animation(.linear(duration: 0.5).delay(0.75), value: progress)
                    .frame(width: 8, height: 8)
                Spacer()
                Circle()
                    .fill(progress == .end ? Color.primaryOrange : Color.secondaryOrange)
                    .frame(width: 8, height: 8)
                    .animation(.linear(duration: 0.5).delay(0.75), value: progress)

            }
        }
    }
}

struct EllipticalProgress_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EllipticalProgress(progress: .constant(.start))
            EllipticalProgress(progress: .constant(.mid))
            EllipticalProgress(progress: .constant(.end))
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
