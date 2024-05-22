//
//  MusicKitView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI
import MusicKit

struct MusicKitView: View {
    @State var playlists: MusicItemCollection<Playlist> = []
    let musicKit = MusicKitController()
    
    var body: some View {
        List {
            if (playlists.isEmpty) {
                Text("Loading...")
            } else {
                ForEach(playlists) { playlist in
                    Text(playlist.name)
                }
            }
        }.task {
            if (musicKit.isAuthorized()) {
                if (playlists.isEmpty) {
                    playlists = await musicKit.getAllPlaylists()
                }
            } else {
                let _ = await musicKit.authorize();
            }
        }
    }
}

#Preview {
    MusicKitView()
}
