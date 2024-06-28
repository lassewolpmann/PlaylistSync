//
//  SpotifyLabel.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 28.6.2024.
//

import SwiftUI

struct SpotifyLabel: View {
    var body: some View {
        Label {
            Text("Spotify")
        } icon: {
            Image("SpotifyIcon")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    SpotifyLabel()
}
