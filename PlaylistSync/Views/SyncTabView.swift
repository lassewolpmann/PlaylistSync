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
                StatusView(spotifyController: spotifyController, musicKitController: musicKitController)
                DataView(spotifyController: spotifyController, musicKitController: musicKitController, selectedSource: $selectedSource, selectedTarget: $selectedTarget)
                SyncSettingsView(matchingLimit: $matchingLimit, useAdvancedMatching: $useAdvancedMatching)
                SyncView(spotifyController: spotifyController, musicKitController: musicKitController, selectedSource: selectedSource, selectedTarget: selectedTarget, showSyncSheet: $showSyncSheet)
            }
            .sheet(isPresented: $showSyncSheet, content: {
                if (spotifyController.loadingCommonData || musicKitController.loadingCommonData) {
                    ProgressView {
                        Text("Loading data...")
                    }
                } else {
                    List {
                        switch selectedSource {
                        case .spotify:
                            if let items = spotifyController.commonSongData {
                                ForEach(items, id: \.self) { item in
                                    ItemLabel(name: item.name, author: item.artist_name, imageURL: item.album_artwork_cover?.absoluteString ?? "")
                                }
                            }
                        case .appleMusic:
                            if let items = musicKitController.commonSongData {
                                ForEach(items, id: \.self) { item in
                                    ItemLabel(name: item.name, author: item.artist_name, imageURL: item.album_artwork_cover?.absoluteString ?? "")
                                }
                            }
                        }
                    }
                }
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
