//
//  PlaylistSelection.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI

struct PlaylistSelection: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    var syncController: SyncController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Choose Playlist")
                    .font(.headline)
                
                Spacer()
            }
            
            PlaylistsSeachFilter(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
            
            switch syncController.selectedSource {
            case .spotify:
                SpotifyPlaylists(spotifyController: spotifyController)
            case .appleMusic:
                MusicKitPlaylists(musicKitController: musicKitController)
            }
        }
        .labelStyle(HorizontalAlignedLabel())
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
        )
    }
}

#Preview {
    let spotifyController = SpotifyController()
    spotifyController.authSuccess = true
    spotifyController.playlistOverview = UserPlaylists()
    
    return PlaylistSelection(spotifyController: spotifyController, musicKitController: MusicKitController(), syncController: SyncController())
}
