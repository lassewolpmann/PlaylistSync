//
//  StatusView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import SwiftUI

struct AuthStatus: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Status")
                .font(.headline)
            
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
                    .frame(height: 30)
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
                    .frame(height: 30)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
        )
    }
}

#Preview {
    AuthStatus(spotifyController: SpotifyController(), musicKitController: MusicKitController())
}
