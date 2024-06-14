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
        VStack(alignment: .leading) {
            Text("Choose Playlist")
                .font(.headline)
            
            switch syncController.selectedSource {
            case .spotify:
                if spotifyController.authSuccess {
                    if let playlists = spotifyController.playlistOverview {
                        SpotifyPlaylists(spotifyController: spotifyController, playlists: playlists)
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
                    if let playlists = musicKitController.playlistOverview {
                        MusicKitPlaylists(musicKitController: musicKitController, playlists: playlists)
                    } else {
                        ProgressView {
                            Text("Loading Spotify Playlists")
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
    PlaylistSelection(spotifyController: SpotifyController(), musicKitController: MusicKitController(), syncController: SyncController())
}
