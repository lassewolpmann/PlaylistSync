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
        Section {
            switch syncController.selectedSource {
            case .spotify:
                if let selectedPlaylist = spotifyController.selectedPlaylist {
                    let name = selectedPlaylist.name
                    let author = selectedPlaylist.owner.display_name ?? ""
                    let imageURL = selectedPlaylist.images.first?.url ?? ""
                    
                    ItemLabel(name: name, author: author, imageURL: imageURL)
                }
            case .appleMusic:
                if let selectedPlaylist = musicKitController.selectedPlaylist {
                    let name = selectedPlaylist.name
                    let author = selectedPlaylist.curatorName ?? ""
                    let imageURL = selectedPlaylist.artwork?.url(width: 640, height: 640)?.absoluteString ?? ""
                    
                    ItemLabel(name: name, author: author, imageURL: imageURL)
                }
            }
            
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
        } header: {
            Text("Sync")
        }
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
    List {
        SyncButton(spotifyController: SpotifyController(), musicKitController: MusicKitController(), syncController: SyncController())
    }
}
