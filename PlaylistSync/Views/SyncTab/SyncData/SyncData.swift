//
//  DataView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 12.6.2024.
//

import SwiftUI

struct SyncData: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    @Bindable var syncController: SyncController
    
    var body: some View {
        Section {
            Picker(selection: $syncController.selectedSource) {
                Text("Spotify").tag(Service.spotify)
                Text("Apple Music").tag(Service.appleMusic)
            } label: {
                Label {
                    Text("Source")
                } icon: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            
            Picker(selection: $syncController.selectedTarget) {
                Text("Spotify").tag(Service.spotify)
                Text("Apple Music").tag(Service.appleMusic)
            } label: {
                Label {
                    Text("Target")
                } icon: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            PlaylistSelection(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
        } header: {
            Text("Data")
        }
    }
}

#Preview {
    List {
        SyncData(spotifyController: SpotifyController(), musicKitController: MusicKitController(), syncController: SyncController())
    }
}
