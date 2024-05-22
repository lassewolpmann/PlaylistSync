//
//  ContentView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import SwiftUI

struct ContentView: View {

    
    
    var body: some View {
        TabView {
            SpotifyView()
                .tabItem {
                    Label("Spotify", systemImage: "music.note")
                }
            
            MusicKitView()
                .tabItem {
                    Label("Apple Music", systemImage: "music.note")
                }
        }
    }
}

#Preview {
    ContentView()
}
