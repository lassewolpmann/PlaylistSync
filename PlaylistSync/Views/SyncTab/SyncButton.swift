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
    var syncController: SyncController
        
    var body: some View {
        NavigationLink {
            SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
        } label: {
            switch syncController.selectedTarget {
            case .spotify:
                Label("Sync Playlist to Spotify", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
            case .appleMusic:
                Label("Sync Playlist to Apple Music", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
            }
        }
        .disabled(checkForDisabledButton())
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
        )
    }
    
    func checkForDisabledButton() -> Bool {
        var sourceDisabled = true
        var targetDisabled = true
        var sameSourceAndTarget = true
        var playlistIsNil = true
        
        switch syncController.selectedSource {
        case .spotify:
            sourceDisabled = !spotifyController.authSuccess
            playlistIsNil = spotifyController.selectedPlaylist == nil
        case .appleMusic:
            sourceDisabled = !musicKitController.authSuccess
            playlistIsNil = musicKitController.selectedPlaylist == nil
        }
        
        switch syncController.selectedTarget {
        case .spotify:
            targetDisabled = !spotifyController.authSuccess
        case .appleMusic:
            targetDisabled = !musicKitController.authSuccess
        }
        
        sameSourceAndTarget = syncController.selectedSource == syncController.selectedTarget
        
        if (sourceDisabled || targetDisabled || sameSourceAndTarget || playlistIsNil) {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    SyncButton(spotifyController: SpotifyController(), musicKitController: MusicKitController(), syncController: SyncController())
}
