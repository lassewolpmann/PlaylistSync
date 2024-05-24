//
//  MusicKitPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 24.5.2024.
//

import SwiftUI
import MusicKit

struct MusicKitPlaylists: View {
    @Environment(MusicKitController.self) private var musicKit
    @State private var playlists: MusicItemCollection<Playlist>?
    
    var body: some View {
        List {
            if (playlists != nil) {
                ForEach(playlists ?? [], id: \.id) { playlist in
                    NavigationLink {
                        MusicKitPlaylistView(playlist: playlist)
                    } label: {
                        ItemLabel(
                            name: playlist.name,
                            author: playlist.curatorName ?? "",
                            imageURL: playlist.artwork?.url(width: 50, height: 50)?.absoluteString ?? ""
                        )
                    }
                }
            } else {
                Text("Loading...")
            }
        }
        .task {
            if (playlists == nil) {
                playlists = await musicKit.getUserPlaylists()
            }
        }
        .refreshable {
            playlists = await musicKit.getUserPlaylists()
        }
    }
}

#Preview {
    MusicKitPlaylists()
        .environment(MusicKitController())
}
