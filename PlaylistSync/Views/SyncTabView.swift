//
//  SyncView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import SwiftUI
import MusicKit

struct SyncTabView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    @Bindable var syncController: SyncController
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .center) {
                    AuthStatus(spotifyController: spotifyController, musicKitController: musicKitController)
                    DataSelection(syncController: syncController)
                    PlaylistSelection(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
                    SyncButton(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
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
    musicKitController.authSuccess = false
    
    return SyncTabView(spotifyController: spotifyController, musicKitController: musicKitController, syncController: SyncController())
}
