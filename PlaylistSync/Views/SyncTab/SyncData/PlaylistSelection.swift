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
                    if let playlists = spotifyController.playlistOverview {
                        LabeledContent {
                            TextField("Search", text: $spotifyController.playlistOverviewFilter)
                        } label: {
                            Image(systemName: "magnifyingglass.circle")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.background)
                        )
                        
                        let filteredPlaylists = playlists.items.filter { playlist in
                            if (spotifyController.playlistOverviewFilter != "") {
                                return playlist.name.lowercased().contains(spotifyController.playlistOverviewFilter.lowercased())
                            } else {
                                return true
                            }
                        }
                        SpotifyPlaylists(spotifyController: spotifyController, playlists: filteredPlaylists)
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
                        LabeledContent {
                            TextField("Search", text: $musicKitController.playlistOverviewFilter)
                        } label: {
                            Image(systemName: "magnifyingglass.circle")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.background)
                        )
                        
                        let filteredPlaylists = playlists.filter { playlist in
                            if (musicKitController.playlistOverviewFilter != "") {
                                return playlist.name.lowercased().contains(musicKitController.playlistOverviewFilter.lowercased())
                            } else {
                                return true
                            }
                        }
                        
                        MusicKitPlaylists(musicKitController: musicKitController, playlists: filteredPlaylists)
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
    let spotifyController = SpotifyController()
    spotifyController.authSuccess = true
    spotifyController.playlistOverview = UserPlaylists()
    
    return PlaylistSelection(spotifyController: spotifyController, musicKitController: MusicKitController(), syncController: SyncController())
}
