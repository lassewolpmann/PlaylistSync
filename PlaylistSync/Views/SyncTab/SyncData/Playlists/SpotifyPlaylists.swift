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
        ScrollView(.horizontal) {
            LazyHStack(spacing: 22) {
                ForEach(playlists.items, id: \.self) { playlist in
                    VStack(spacing: 10) {
                        PlaylistSelectionImage(url: playlist.images.first?.url ?? "", name: playlist.name, author: playlist.owner.display_name ?? "")
                        
                        Button {
                            spotifyController.selectedPlaylist = playlist
                        } label: {
                            if (spotifyController.selectedPlaylist == playlist) {
                                Label {
                                    Text("Selected")
                                } icon: {
                                    Image(systemName: "checkmark.circle")
                                }
                            } else {
                                Label {
                                    Text("Select")
                                } icon: {
                                    Image(systemName: "circle")
                                }
                            }
                        }
                    }
                    .scrollTransition(
                        axis: .horizontal
                    ) { content, phase in
                        content
                            .opacity(1 - (abs(phase.value) * 0.8))
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 44)
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    NavigationStack {
        SpotifyPlaylists(spotifyController: SpotifyController(), playlists: UserPlaylists())
            .navigationTitle("Spotify")
    }
}
