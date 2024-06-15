//
//  SpotifyPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI

struct SpotifyPlaylists: View {
    @Bindable var spotifyController: SpotifyController
    let playlists: [UserPlaylists.Playlist]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 11) {
                ForEach(playlists, id: \.self) { playlist in
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
                        .padding(.bottom, 10)
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
        .contentMargins(.horizontal, 22)
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    NavigationStack {
        SpotifyPlaylists(spotifyController: SpotifyController(), playlists: UserPlaylists().items)
            .navigationTitle("Spotify")
    }
}
