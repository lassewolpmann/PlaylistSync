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
    @Environment(MusicKitController.self) private var musicKit
        
    var body: some View {
        NavigationStack {
            Group {
                if (spotify.authSuccess) {
                    SpotifyPlaylists()
                        .environment(spotify)
                } else {
                    Text("Authorize Spotify in Settings.")
                }
            }
            .navigationTitle("Spotify")
        }
    }
}

#Preview {
    SpotifyView()
        .tabItem {
            Label("Spotify", systemImage: "music.note")
        }
        .environment(SpotifyController())
        .environment(MusicKitController())
}
