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
    var syncController: SyncController
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .center) {
                    // AuthStatus(spotifyController: spotifyController, musicKitController: musicKitController)
                    DataSelection(syncController: syncController)
                    
                    if let source = syncController.selectedSource, let target = syncController.selectedTarget {
                        PlaylistSelection(spotifyController: spotifyController, musicKitController: musicKitController, source: source)
                        SyncButton(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController, source: source, target: target)
                    }
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Sync")
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    let musicKitController = MusicKitController()
    
    spotifyController.authSuccess = true
    spotifyController.playlistOverview = UserPlaylists()
    musicKitController.authSuccess = true
    
    return SyncTabView(spotifyController: spotifyController, musicKitController: musicKitController, syncController: SyncController())
}
