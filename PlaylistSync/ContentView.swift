//
//  ContentView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import SwiftUI

struct ContentView: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    var body: some View {
        if (spotifyController.authSuccess == false || musicKitController.authSuccess == false) {
            SettingsView(spotifyController: spotifyController, musicKitController: musicKitController)
        } else {
            Text("Test")
            
            /*
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
             */
        }
    }
}

#Preview {
    ContentView(spotifyController: SpotifyController(), musicKitController: MusicKitController())
}
