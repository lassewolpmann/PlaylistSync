//
//  ContentView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var spotify = SpotifyController()
    @State private var musicKit = MusicKitController()
    
    var body: some View {
        TabView {
            SpotifyView()
                .tabItem {
                    Label("Spotify", systemImage: "music.note")
                }
                .environment(spotify)
                .environment(musicKit)
            
            MusicKitView()
                .tabItem {
                    Label("Apple Music", systemImage: "music.note")
                }
                .environment(spotify)
                .environment(musicKit)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .environment(spotify)
                .environment(musicKit)
        }
    }
}

#Preview {
    ContentView()
}
