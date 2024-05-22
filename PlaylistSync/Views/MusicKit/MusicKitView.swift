//
//  MusicKitView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI
import MusicKit

struct MusicKitView: View {
    @State var tracks: MusicItemCollection<Track> = []
    let musicKit = MusicKitController()
    
    var body: some View {
        VStack {
            Button {
                Task {
                    if (musicKit.isAuthorized()) {
                        tracks = await musicKit.getAllPlaylists()
                    } else {
                        let _ = await musicKit.authorize();
                    }
                }
            } label: {
                Text("Get all Playlists")
            }
            
            
            
            Text("Tracks")
            List {
                ForEach(tracks) { track in
                    Text("\(track.title) by \(track.artistName)")
                }
            }
        }
    }
}

#Preview {
    MusicKitView()
}
