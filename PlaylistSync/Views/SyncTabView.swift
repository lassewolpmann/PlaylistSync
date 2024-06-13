//
//  SyncView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import SwiftUI
import MusicKit

enum Service: String, Identifiable {
    case spotify, appleMusic
    var id: Self { self }
}

struct SyncTabView: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    @State var selectedSource: Service = .spotify
    @State var selectedTarget: Service = .appleMusic
    
    @State var matchingLimit = 5.0
    @State var useAdvancedMatching = false
    
    @State var showSyncSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                AuthStatus(spotifyController: spotifyController, musicKitController: musicKitController)
                SyncData(spotifyController: spotifyController, musicKitController: musicKitController, selectedSource: $selectedSource, selectedTarget: $selectedTarget)
                SyncSettings(matchingLimit: $matchingLimit, useAdvancedMatching: $useAdvancedMatching)
                SyncButton(spotifyController: spotifyController, musicKitController: musicKitController, selectedSource: selectedSource, selectedTarget: selectedTarget, showSyncSheet: $showSyncSheet)
            }
            .sheet(isPresented: $showSyncSheet, content: {
                SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, selectedSource: selectedSource, selectedTarget: selectedTarget, matchingLimit: matchingLimit, useAdvancedMatching: useAdvancedMatching)
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
    
    return SyncTabView(spotifyController: spotifyController, musicKitController: musicKitController)
}
