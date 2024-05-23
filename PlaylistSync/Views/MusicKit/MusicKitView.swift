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
    @Environment(MusicKitController.self) private var musicKit
    
    var body: some View {
        if (musicKit.authSuccess) {
            if (playlists.isEmpty) {
                Text("Loading...")
            } else {
                List {
                    ForEach(playlists) { playlist in
                        Text(playlist.name)
                    }
                }
                .task {
                    if (musicKit.authSuccess) {
                        if (playlists.isEmpty) {
                            playlists = await musicKit.getAllPlaylists()
                        }
                    } else {
                        print("No auth.")
                        // let _ = await musicKit.authorize();
                    }
                }
            }
        } else {
            Text("Authorize MusicKit in Settings.")
        }
    }
}

#Preview {
    MusicKitView()
        .environment(MusicKitController())
}
