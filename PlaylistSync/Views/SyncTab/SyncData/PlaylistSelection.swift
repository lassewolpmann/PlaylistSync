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
        NavigationLink {
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
                        Text("Authorize Spotify Access before choosing a Playlist!")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .symbolRenderingMode(.multicolor)
                    .labelStyle(HorizontalAlignedLabel())
                    .padding()
                }
                
            case .appleMusic:
                if musicKitController.authSuccess {
                    if let playlists = musicKitController.playlistOverview {
                        MusicKitPlaylists(musicKitController: musicKitController, playlists: playlists)
                    } else {
                        ProgressView {
                            Text("Loading Apple Music Playlists")
                        }.task {
                            musicKitController.playlistOverview = await musicKitController.getUserPlaylists()
                        }
                    }
                } else {
                    Label {
                        Text("Authorize Apple Music Access before choosing a Playlist!")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .symbolRenderingMode(.multicolor)
                    .labelStyle(HorizontalAlignedLabel())
                    .padding()
                }
                
            }
        } label: {
            Label {
                Text("Choose Playlist")
            } icon: {
                switch syncController.selectedSource {
                case .spotify:
                    Image("SpotifyIcon")
                        .resizable()
                        .scaledToFit()
                case .appleMusic:
                    Image("AppleMusicIcon")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
}

#Preview {
    PlaylistSelection(spotifyController: SpotifyController(), musicKitController: MusicKitController(), syncController: SyncController())
}
