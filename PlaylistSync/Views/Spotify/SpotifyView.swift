//
//  SpotifyView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI
import AuthenticationServices

struct SpotifyView: View {
    @State private var spotify = SpotifyController()
    
    var body: some View {
        VStack {
            if (spotify.authSuccess) {
                SpotifyPlaylists()
                    .environment(spotify)
            } else {
                SpotifyAuthButton()
                    .environment(spotify)
            }
        }
    }
}

#Preview {
    SpotifyView()
}
