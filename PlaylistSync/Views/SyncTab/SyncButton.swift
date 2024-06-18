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
    
    @State var showSettingsSheet = false
        
    var body: some View {
        HStack {
            NavigationLink {
                SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
            } label: {
                Label {
                    switch syncController.selectedTarget {
                    case .spotify:
                        Text("Sync Playlist to Spotify")
                    case .appleMusic:
                        Text("Sync Playlist to Apple Music")
                    }
                } icon: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
            .disabled(checkForDisabledButton())
            
            Divider()
            
            Button {
                showSettingsSheet.toggle()
            } label: {
                Image(systemName: "gear")
            }
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
        )
        .sheet(isPresented: $showSettingsSheet, content: {
            SyncSettings(syncController: syncController)
                .presentationDetents([.medium, .large])
        })
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
