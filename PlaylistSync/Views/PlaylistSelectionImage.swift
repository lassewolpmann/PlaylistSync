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
    let name: String
    let author: String
    
    var body: some View {
        let cornerRadius = 15.0
        Rectangle()
            .fill(.tertiary)
            .aspectRatio(1.0, contentMode: .fit)
            .containerRelativeFrame(.horizontal)
            .overlay {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .blur(radius: 10.0)
                            .clipped()
                    } placeholder: {
                        ProgressView {
                            Text("Loading Image")
                        }
                    }
                    
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .clear, location: 0),
                            Gradient.Stop(color: .primary, location: 0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                        
                        Text(author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}

#Preview {
    PlaylistSelectionImage(url: "", name: "", author: "")
}
