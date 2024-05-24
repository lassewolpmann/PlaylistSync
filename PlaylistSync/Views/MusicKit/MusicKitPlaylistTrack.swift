//
//  MusicKitPlaylistTrack.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 24.5.2024.
//

import SwiftUI
import MusicKit

struct MusicKitPlaylistTrack: View {
    @Environment(MusicKitController.self) private var musicKit
    var track: MusicItemCollection<Track>.Element?
    
    @State var song: Song?
    
    var body: some View {
        ItemLabel(
            name: song?.title ?? "",
            author: song?.artistName ?? "",
            imageURL: song?.artwork?.url(width: 320, height: 320)?.absoluteString ?? ""
        )
        .task {
            song = await musicKit.getSong(track: track)
        }
    }
}

#Preview {
    MusicKitPlaylistTrack()
        .environment(MusicKitController())
}
