//
//  PlaylistSelectionImage.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI

struct PlaylistSelectionImage: View {
    @Environment(\.colorScheme) var colorScheme

    let url: String
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .scaledToFit()
                .blur(radius: 5)
                .clipped()
                .overlay {
                    if (colorScheme == .dark) {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .clear, location: 0.5),
                                Gradient.Stop(color: .black.opacity(0.8), location: 0.5),
                                Gradient.Stop(color: .black.opacity(0.7), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .clear, location: 0.5),
                                Gradient.Stop(color: .white.opacity(0.8), location: 0.5),
                                Gradient.Stop(color: .white.opacity(0.7), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
        } placeholder: {
            RoundedRectangle(cornerRadius: 15)
                .fill(.primary)
                .overlay {
                    if (colorScheme == .dark) {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .clear, location: 0.5),
                                Gradient.Stop(color: .black.opacity(0.8), location: 0.5),
                                Gradient.Stop(color: .black.opacity(0.7), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .clear, location: 0.5),
                                Gradient.Stop(color: .white.opacity(0.8), location: 0.5),
                                Gradient.Stop(color: .white.opacity(0.7), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
        }
    }
}

#Preview {
    PlaylistSelectionImage(url: "")
}
