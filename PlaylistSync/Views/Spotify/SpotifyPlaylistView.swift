//
//  SpotifyPlaylistView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 23.5.2024.
//

import SwiftUI

struct SpotifyPlaylistView: View {
    @Environment(SpotifyController.self) private var spotify

    let playlistID: String
    @State var playlist: SpotifyPlaylist?
    
    var body: some View {
        List {
            if (playlist != nil) {
                ForEach(playlist?.tracks.items ?? [], id: \.track.id) { item in
                    let authorNames = item.track.artists.map { $0.name }
                    SpotifyLabel(
                        name: item.track.name,
                        author: authorNames.joined(separator: ", "),
                        imageURL: item.track.album.images.first?.url ?? ""
                    )
                }
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
}
