//
//  SpotifyPlaylistView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 23.5.2024.
//

import SwiftUI

struct SpotifyPlaylistView: View {
    @Environment(SpotifyController.self) private var spotify
    @Environment(MusicKitController.self) private var musicKit

    let playlistID: String
    @State var playlist: SpotifyPlaylist?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if (playlist != nil) {
                List {
                    Section {
                        if (playlist != nil) {
                            ForEach(playlist?.tracks.items ?? [], id: \.track.id) { item in
                                ItemLabel(
                                    name: item.track.name,
                                    author: item.track.artists.first?.name ?? "",
                                    imageURL: item.track.album.images.first?.url ?? ""
                                )
                            }
                        } else {
                            ProgressView()
                        }
                    } header: {
                        Text("Songs")
                    }
                }
                
                SpotifySyncButton(playlist: playlist)
                    .environment(spotify)
                    .environment(musicKit)
            } else {
                ProgressView()
            }
            
            
        }
        .navigationTitle(playlist?.name ?? "")
        .task {
            do {
                playlist = try await spotify.getPlaylist(playlistID: playlistID)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SpotifyPlaylistView(playlistID: "3cEYpjA9oz9GiPac4AsH4n")
        .environment(SpotifyController())
        .environment(MusicKitController())
}
