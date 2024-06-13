//
//  SyncView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 12.6.2024.
//

import SwiftUI

struct SyncButton: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    var selectedSource: Service
    var selectedTarget: Service
    
    @Binding var showSyncSheet: Bool
    
    var body: some View {
        Section {
            switch selectedSource {
            case .spotify:
                if let playlist = spotifyController.playlistToSync {
                    ItemLabel(
                        name: playlist.name,
                        author: playlist.owner.display_name ?? "",
                        imageURL: playlist.images.first?.url ?? ""
                    )
                }
            case .appleMusic:
                if let playlist = musicKitController.playlistToSync {
                    ItemLabel(
                        name: playlist.name,
                        author: playlist.curatorName ?? "",
                        imageURL: playlist.artwork?.url(width: 50, height: 50)?.absoluteString ?? ""
                    )
                }
            }
            
            Button {
                showSyncSheet.toggle()
            } label: {
                switch selectedTarget {
                case .spotify:
                    Label("Sync Playlist to Spotify", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                case .appleMusic:
                    Label("Sync Playlist to Apple Music", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                }
            }
            .disabled(checkForDisabledButton())
        } header: {
            Text("Sync")
        }
    }
    
    func checkForDisabledButton() -> Bool {
        var sourceDisabled = true
        var targetDisabled = true
        var sameSourceAndTarget = true
        
        switch selectedSource {
        case .spotify:
            sourceDisabled = !spotifyController.authSuccess
        case .appleMusic:
            sourceDisabled = !musicKitController.authSuccess
        }
        
        switch selectedTarget {
        case .spotify:
            targetDisabled = !spotifyController.authSuccess
        case .appleMusic:
            targetDisabled = !musicKitController.authSuccess
        }
        
        sameSourceAndTarget = selectedSource == selectedTarget
        
        if (sourceDisabled || targetDisabled || sameSourceAndTarget ) {
            return true
        } else {
            switch selectedSource {
            case .spotify:
                if spotifyController.playlistToSync == nil {
                    return true
                } else {
                    return false
                }
            case .appleMusic:
                if musicKitController.playlistToSync == nil {
                    return true
                } else {
                    return false
                }
            }
        }
    }
}

#Preview {
    List {
        SyncButton(spotifyController: SpotifyController(), musicKitController: MusicKitController(), selectedSource: Service.spotify, selectedTarget: Service.appleMusic, showSyncSheet: .constant(false))
    }
}
