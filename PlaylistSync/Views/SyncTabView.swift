//
//  SyncView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import SwiftUI
import MusicKit

struct SyncTabView: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    @Bindable var syncController: SyncController
    
    var body: some View {
        NavigationStack {
            List {
                AuthStatus(spotifyController: spotifyController, musicKitController: musicKitController)
                SyncData(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
                SyncSettings(syncController: syncController)
                SyncButton(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
            }
            .sheet(isPresented: $syncController.showSyncSheet, content: {
                SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
            })
            .navigationTitle("Sync")
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    let musicKitController = MusicKitController()
    
    spotifyController.authSuccess = true
    musicKitController.authSuccess = true
    
    return SyncTabView(spotifyController: spotifyController, musicKitController: musicKitController, syncController: SyncController())
}
