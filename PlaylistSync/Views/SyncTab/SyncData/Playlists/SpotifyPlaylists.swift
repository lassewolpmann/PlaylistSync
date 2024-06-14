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
            HStack(spacing: 16) {
                ForEach(playlists.items, id: \.self) { playlist in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomLeading) {
                            PlaylistSelectionImage(url: playlist.images.first?.url ?? "")
                        
                            VStack(alignment: .leading) {
                                Text(playlist.name)
                                    .font(.headline)
                                
                                if let creator = playlist.owner.display_name {
                                    Text(creator)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
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
                                .padding(.top, 10)
                            }
                            .padding()
                        }
                        .containerRelativeFrame(.horizontal)
                        .clipShape(.rect(cornerRadius: 32))
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
        .contentMargins(.horizontal, 32)
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    NavigationStack {
        SpotifyPlaylists(spotifyController: SpotifyController(), playlists: UserPlaylists())
            .navigationTitle("Spotify")
    }
}
