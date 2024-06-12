//
//  StatusView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import SwiftUI

struct StatusView: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    var body: some View {
        Section {
            Label {
                HStack {
                    Text("Spotify")
                    Spacer()
                    Image(systemName: spotifyController.authSuccess ? "checkmark" : "xmark")
                        .foregroundStyle(spotifyController.authSuccess ? .green : .red)
                }
            } icon: {
                Image("SpotifyIcon")
                    .resizable()
                    .scaledToFit()
            }
            
            Label {
                HStack {
                    Text("Apple Music")
                    Spacer()
                    Image(systemName: musicKitController.authSuccess ? "checkmark" : "xmark")
                        .foregroundStyle(musicKitController.authSuccess ? .green : .red)
                }
            } icon: {
                Image("AppleMusicIcon")
                    .resizable()
                    .scaledToFit()
            }
        } header: {
            Text("Status")
        }
    }
}

#Preview {
    List {
        StatusView(spotifyController: SpotifyController(), musicKitController: MusicKitController())
    }
}
