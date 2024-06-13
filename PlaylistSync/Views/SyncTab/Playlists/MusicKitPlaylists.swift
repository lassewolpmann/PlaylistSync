//
//  MusicKitPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI
import MusicKit

struct MusicKitPlaylists: View {
    @Bindable var musicKitController: MusicKitController
    @State private var playlists: MusicItemCollection<Playlist>?
    
    var body: some View {
        if let playlists {
            List(playlists, id: \.self, selection: $musicKitController.playlistToSync) { playlist in
                ItemLabel(
                    name: playlist.name,
                    author: playlist.curatorName ?? "",
                    imageURL: playlist.artwork?.url(width: 50, height: 50)?.absoluteString ?? ""
                )
            }
            .navigationTitle("Your Apple Music Playlists")
        } else {
            ProgressView {
                Text("Loading your Apple Music Playlists...")
            }
            .task {
                playlists = await musicKitController.getUserPlaylists()
            }
        }
    }
}

#Preview {
    MusicKitPlaylists(musicKitController: MusicKitController())
}
