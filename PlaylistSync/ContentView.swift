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
        TabView {
            SyncTabView(spotifyController: spotifyController, musicKitController: musicKitController)
            .tabItem {
                Label("Sync", systemImage: "arrow.triangle.2.circlepath")
            }
            
            SettingsTabView(spotifyController: spotifyController, musicKitController: musicKitController)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    let musicKitController = MusicKitController()
    
    spotifyController.authSuccess = true
    musicKitController.authSuccess = true
    
    return ContentView(spotifyController: spotifyController, musicKitController: musicKitController)
}
