//
//  SpotifyPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI

struct SpotifyPlaylists: View {
    @Bindable var spotifyController: SpotifyController
    @State var playlists: UserPlaylists?

    var body: some View {
        if let playlists {
            List(playlists.items, id: \.self, selection: $spotifyController.playlistToSync) { playlist in
                ItemLabel(
                    name: playlist.name,
                    author: playlist.owner.display_name ?? "",
                    imageURL: playlist.images.first?.url ?? ""
                )
            }
            .navigationTitle("Your Spotify Playlists")
        } else {
            ProgressView {
                Text("Loading your Spotify Playlists...")
            }
            .task {
                do {
                    playlists = try await spotifyController.getUserPlaylists()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SpotifyPlaylists(spotifyController: SpotifyController(), playlists: UserPlaylists())
            .navigationTitle("Spotify")
    }
}
