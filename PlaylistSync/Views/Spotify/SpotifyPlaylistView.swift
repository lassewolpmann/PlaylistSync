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
    @State var playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject]?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let playlist, let playlistItems {
                List(playlistItems, id: \.id) { item in
                    ItemLabel(
                        name: item.name,
                        author: item.artists.first?.name ?? "",
                        imageURL: item.album.images.first?.url ?? ""
                    )
                }
                
                SpotifySyncButton(playlistName: playlist.name, playlistItems: playlistItems)
                    .environment(spotify)
                    .environment(musicKit)
            } else {
                VStack {
                    Text("Loading Playlist")
                    ProgressView()
                }
            }
            
            
        }
        .navigationTitle(playlist?.name ?? "")
        .task {
            do {
                playlist = try await spotify.getPlaylist(playlistID: playlistID)
                
                if let playlist {
                    playlistItems = try await spotify.getPlaylistItems(url: playlist.tracks.href, total: playlist.tracks.total)
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SpotifyPlaylistView(playlistID: "3cEYpjA9oz9GiPac4AsH4n", playlist: SpotifyPlaylist(), playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject()])
        .environment(SpotifyController())
        .environment(MusicKitController())
}
