//
//  PlaylistSelection.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI

struct PlaylistSelection: View {
    @Bindable var spotifyController: SpotifyController
    @Bindable var musicKitController: MusicKitController
    var syncController: SyncController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Choose Playlist")
                    .font(.headline)
                
                Spacer()
            }
                        
            switch syncController.selectedSource {
            case .spotify:
                if spotifyController.authSuccess {
                    if spotifyController.playlistOverview != nil {
                        PlaylistsSeachFilter(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
                        
                        Playlists(spotifyController: spotifyController, musicKitController: musicKitController, spotifyPlaylists: spotifyController.filteredPlaylists)
                    } else {
                        ProgressView {
                            Text("Loading Spotify Playlists")
                        }.task {
                            do {
                                spotifyController.playlistOverview = try await spotifyController.getUserPlaylists()
                            } catch {
                                print(error)
                            }
                        }
                    }
                } else {
                    Label {
                        Text("Authorize Spotify in Settings for Playlist Access.")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .labelStyle(HorizontalAlignedLabel())
                }
            case .appleMusic:
                if musicKitController.authSuccess {
                    if musicKitController.playlistOverview != nil {
                        PlaylistsSeachFilter(spotifyController: spotifyController, musicKitController: musicKitController, syncController: syncController)
                        
                        Playlists(spotifyController: spotifyController, musicKitController: musicKitController, musicKitPlaylists: musicKitController.filteredPlaylists)
                    } else {
                        ProgressView {
                            Text("Loading Apple Music Playlists")
                        }.task {
                            musicKitController.playlistOverview = await musicKitController.getUserPlaylists()
                        }
                    }
                } else {
                    Label {
                        Text("Authorize Apple Music in Settings for Playlist Access.")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .labelStyle(HorizontalAlignedLabel())
                }
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
    let spotifyController = SpotifyController()
    spotifyController.authSuccess = true
    spotifyController.playlistOverview = UserPlaylists()
    
    return PlaylistSelection(spotifyController: spotifyController, musicKitController: MusicKitController(), syncController: SyncController())
}
