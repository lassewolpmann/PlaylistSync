//
//  SpotifyPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI

struct SpotifyPlaylists: View {
    @Bindable var spotifyController: SpotifyController
    let playlists: UserPlaylists

    var body: some View {
        List(playlists.items, id: \.self, selection: $spotifyController.selectedPlaylist) { playlist in
            let name = playlist.name
            let author = playlist.owner.display_name ?? ""
            let imageURL = playlist.images.first?.url ?? ""
            
            ItemLabel(
                name: name,
                author: author,
                imageURL: imageURL
            )
        }
        .navigationTitle("Your Spotify Playlists")
    }
}

#Preview {
    NavigationStack {
        SpotifyPlaylists(spotifyController: SpotifyController(), playlists: UserPlaylists())
            .navigationTitle("Spotify")
    }
}
