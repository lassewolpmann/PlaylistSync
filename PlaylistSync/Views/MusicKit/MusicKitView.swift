//
//  MusicKitView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI
import MusicKit

struct MusicKitView: View {
    @Environment(SpotifyController.self) private var spotify
    @Environment(MusicKitController.self) private var musicKit
    
    @State var playlists: MusicItemCollection<Playlist>?

    var body: some View {
        NavigationStack {
            Group {
                if (musicKit.authSuccess) {
                    MusicKitPlaylists(musicKitController: musicKit)
                } else {
                    Text("Authorize MusicKit in Settings.")
                }
            }
            .navigationTitle("Apple Music")
        }
    }
}

#Preview {
    MusicKitView()
        .environment(SpotifyController())
        .environment(MusicKitController())
}
