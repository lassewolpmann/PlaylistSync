//
//  SpotifyPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 28.6.2024.
//

import SwiftUI

struct SpotifyPlaylists: View {
    @Bindable var spotifyController: SpotifyController
    
    var body: some View {
        if spotifyController.authSuccess {
            if spotifyController.playlistOverview != nil {
                if spotifyController.filteredPlaylists.isEmpty {
                    Label {
                        Text("No Playlists found.")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .symbolRenderingMode(.multicolor)
                } else {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 11) {
                            ForEach(spotifyController.filteredPlaylists, id: \.self) { playlist in
                                PlaylistArtwork(spotifyPlaylist: playlist).id(playlist)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $spotifyController.selectedPlaylist)
                    .contentMargins(.horizontal, 22)
                    .scrollTargetBehavior(.paging)
                }
            } else {
                ProgressView {
                    Text("Loading your Spotify Playlists")
                }
                .task {
                    do {
                        try await spotifyController.getUserPlaylists()
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            Label {
                Text("Authorize Spotify in Settings for Playlist Access.")
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
            .symbolRenderingMode(.multicolor)
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    spotifyController.authSuccess = true
    spotifyController.playlistOverview = UserPlaylists()
    
    return SpotifyPlaylists(spotifyController: spotifyController)
}
