//
//  PlaylistSyncApp.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import SwiftUI

@main
struct PlaylistSyncApp: App {
    @State private var spotifyController = SpotifyController()
    @State private var musicKitController = MusicKitController()
    
    var body: some Scene {
        WindowGroup {
            ContentView(spotifyController: spotifyController, musicKitController: musicKitController)
        }
    }
}
