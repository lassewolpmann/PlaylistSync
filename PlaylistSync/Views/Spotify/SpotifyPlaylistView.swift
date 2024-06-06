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
    
    @State var showSheet: Bool = false
    
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
                .sheet(isPresented: $showSheet, content: {
                    SpotifySyncSheet(spotifyPlaylistName: playlist.name, spotifyPlaylistItems: playlistItems)
                        .environment(musicKit)
                        .environment(spotify)
                        .presentationBackground(.ultraThinMaterial)
                })
                
                SpotifySyncButton(showSheet: $showSheet, playlistName: playlist.name)
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
    NavigationStack {
        SpotifyPlaylistView(playlistID: "3cEYpjA9oz9GiPac4AsH4n", playlist: SpotifyPlaylist(), playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject()])
            .environment(SpotifyController())
            .environment(MusicKitController())
    }
    
}
