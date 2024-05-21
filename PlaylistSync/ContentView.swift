//
//  ContentView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @State var tracks: MusicItemCollection<Track> = []
    
    var body: some View {
        VStack {
            Button {
                Task {
                    if (isAuthorized()) {
                        tracks = await getAllPlaylists()
                    } else {
                        let _ = await authorize();
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
        .padding()
    }
}

#Preview {
    ContentView()
}
