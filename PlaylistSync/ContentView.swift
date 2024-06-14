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
    var syncController: SyncController
    
    var body: some View {
        TabView {
            SyncTabView(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
            .tabItem {
                Label("Sync", systemImage: "arrow.triangle.2.circlepath")
            }
            
            SettingsTabView(spotifyController: spotifyController, musicKitController: musicKitController)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .disabled(syncController.addingPlaylist)
        .overlay {
            if (syncController.addingPlaylist) {
                ProgressView {
                    Text("Adding Playlist to your Library")
                        .font(.headline)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
            }
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    let musicKitController = MusicKitController()
    
    spotifyController.authSuccess = true
    musicKitController.authSuccess = true
    
    return ContentView(spotifyController: spotifyController, musicKitController: musicKitController, syncController: SyncController())
}
