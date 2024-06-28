//
//  MusicKitPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 28.6.2024.
//

import SwiftUI

struct MusicKitPlaylists: View {
    @Bindable var musicKitController: MusicKitController
    
    var body: some View {
        if musicKitController.authSuccess {
            if musicKitController.playlistOverview != nil {
                if musicKitController.filteredPlaylists.isEmpty {
                    Label {
                        Text("No Playlists found.")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .symbolRenderingMode(.multicolor)
                } else {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 11) {
                            ForEach(musicKitController.filteredPlaylists, id: \.self) { playlist in
                                PlaylistArtwork(musicKitPlaylist: playlist).id(playlist)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $musicKitController.selectedPlaylist)
                    .contentMargins(.horizontal, 22)
                    .scrollTargetBehavior(.paging)
                }
            } else {
                ProgressView {
                    Text("Loading your Apple Music Playlists")
                }
                .task {
                    await musicKitController.getUserPlaylists()
                }
            }
        } else {
            Label {
                Text("Authorize Apple Music in Settings for Playlist Access.")
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
            .symbolRenderingMode(.multicolor)
        }
    }
}

#Preview {
    MusicKitPlaylists(musicKitController: MusicKitController())
}
