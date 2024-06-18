//
//  SpotifyPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI
import MusicKit

struct Playlists: View {
    @Bindable var spotifyController: SpotifyController
    @Bindable var musicKitController: MusicKitController
    
    var spotifyPlaylists: [UserPlaylists.Playlist]?
    var musicKitPlaylists: [Playlist]?

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 11) {
                if let spotifyPlaylists {
                    ForEach(spotifyPlaylists, id: \.self) { playlist in
                        PlaylistSelectionImage(spotifyController: spotifyController, musicKitController: musicKitController, spotifyPlaylist: playlist)
                    }
                } else if let musicKitPlaylists {
                    ForEach(musicKitPlaylists, id: \.self) { playlist in
                        PlaylistSelectionImage(spotifyController: spotifyController, musicKitController: musicKitController, musicKitPlaylist: playlist)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 22)
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    NavigationStack {
        Playlists(spotifyController: SpotifyController(), musicKitController: MusicKitController(), spotifyPlaylists: UserPlaylists().items)
            .navigationTitle("Spotify")
    }
}
