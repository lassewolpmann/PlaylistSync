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
        if (spotify.authSuccess == false || musicKit.authSuccess == false) {
            SettingsView()
                .environment(spotify)
                .environment(musicKit)
        } else {
            
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
            }
        }
    }
}

#Preview {
    ContentView()
}
