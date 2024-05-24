//
//  MusicKitPlaylistView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 24.5.2024.
//

import SwiftUI
import MusicKit

struct MusicKitPlaylistView: View {
    @Environment(MusicKitController.self) private var musicKit
    var playlist: Playlist?
    
    @State var detailedPlaylist: Playlist?
    
    var body: some View {
        List {
            if (detailedPlaylist != nil) {
                ForEach(detailedPlaylist?.tracks ?? []) { track in
                    MusicKitPlaylistTrack(track: track)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(playlist?.name ?? "")
        .task {
            detailedPlaylist = await musicKit.getPlaylist(playlist: playlist)
        }
    }
}

#Preview {
    MusicKitPlaylistView()
}
