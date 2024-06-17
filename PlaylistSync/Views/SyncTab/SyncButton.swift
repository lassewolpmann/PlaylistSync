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
            Label {
                HStack {
                    switch syncController.selectedTarget {
                    case .spotify:
                        Text("Sync Playlist to Spotify")
                        Image("SpotifyIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .padding(.leading, 5)
                    case .appleMusic:
                        Text("Sync Playlist to Apple Music")
                        Image("AppleMusicIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .padding(.leading, 5)
                    }
                }
            } icon: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
        .font(.headline)
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
