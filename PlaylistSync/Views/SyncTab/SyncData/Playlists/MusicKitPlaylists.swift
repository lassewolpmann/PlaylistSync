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
    let playlists: MusicItemCollection<Playlist>
    
    var body: some View {
        List(playlists, id: \.self, selection: $musicKitController.selectedPlaylist) { playlist in
            let name = playlist.name
            let author = playlist.curatorName ?? ""
            let imageURL = playlist.artwork?.url(width: 640, height: 640)?.absoluteString ?? ""
            
            ItemLabel(
                name: name,
                author: author,
                imageURL: imageURL
            )
        }
        .navigationTitle("Your Apple Music Playlists")
    }
}

#Preview {
    MusicKitPlaylists(musicKitController: MusicKitController(), playlists: [])
}
