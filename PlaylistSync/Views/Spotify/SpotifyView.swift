//
//  SpotifyView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI
import AuthenticationServices

struct SpotifyView: View {
    @Environment(SpotifyController.self) private var spotify
    
    var body: some View {
        if (spotify.authSuccess) {
            SpotifyPlaylists()
                .environment(spotify)
        } else {
            Text("Authorize Spotify in Settings.")
        }
    }
}

#Preview {
    SpotifyView()
        .environment(SpotifyController())
}
