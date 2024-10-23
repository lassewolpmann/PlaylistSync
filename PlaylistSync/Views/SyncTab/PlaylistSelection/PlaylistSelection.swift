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
    
    let source: Service
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Choose Playlist")
                    .font(.headline)
                
                Spacer()
            }
            
            PlaylistsSearchFilter(spotifyController: spotifyController, musicKitController: musicKitController, source: source)
            
            switch source {
            case .spotify:
                if spotifyController.authSuccess {
                    if spotifyController.playlistOverview != nil {
                        if !spotifyController.filteredPlaylists.isEmpty {
                            PlaylistScroll(spotifyController: spotifyController, musicKitController: musicKitController, source: source)
                        } else {
                            NoPlaylistLabel()
                        }
                    } else {
                        PlaylistLoadingProgressView(service: "Spotify", spotifyController: spotifyController)
                    }
                } else {
                    AuthLabel(service: "Spotify")
                }
            case .appleMusic:
                if musicKitController.authSuccess {
                    if musicKitController.playlistOverview != nil {
                        if !musicKitController.filteredPlaylists.isEmpty {
                            PlaylistScroll(spotifyController: spotifyController, musicKitController: musicKitController, source: source)
                        } else {
                            NoPlaylistLabel()
                        }
                    } else {
                        PlaylistLoadingProgressView(service: "Apple Music", musicKitController: musicKitController)
                    }
                } else {
                    AuthLabel(service: "Apple Music")
                }
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

struct PlaylistScroll: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    let source: Service
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 11) {
                    switch source {
                    case .spotify:
                        ForEach(spotifyController.filteredPlaylists, id: \.self) { playlist in
                            PlaylistArtwork(spotifyController: spotifyController, musicKitController: musicKitController, source: source, spotifyPlaylist: playlist)
                        }
                    case .appleMusic:
                        ForEach(musicKitController.filteredPlaylists, id: \.self) { playlist in
                            PlaylistArtwork(spotifyController: spotifyController, musicKitController: musicKitController, source: source, musicKitPlaylist: playlist)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 22)
            .scrollTargetBehavior(.paging)
        }
    }
}

struct NoPlaylistLabel: View {
    var body: some View {
        Label {
            Text("No Playlists found.")
        } icon: {
            Image(systemName: "exclamationmark.triangle")
        }
        .symbolRenderingMode(.multicolor)
    }
}

struct AuthLabel: View {
    let service: String
    
    var body: some View {
        Label {
            Text("Authorize \(service) in Settings for Playlist Access.")
        } icon: {
            Image(systemName: "exclamationmark.triangle")
        }
        .symbolRenderingMode(.multicolor)
    }
}

struct PlaylistLoadingProgressView: View {
    let service: String
    var spotifyController: SpotifyController?
    var musicKitController: MusicKitController?
    
    var body: some View {
        ProgressView {
            Text("Loading your \(service) Playlists")
        }
        .task {
            if let musicKitController {
                await musicKitController.getUserPlaylists()
            } else if let spotifyController {
                do {
                    try await spotifyController.getUserPlaylists()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    spotifyController.authSuccess = true
    spotifyController.playlistOverview = UserPlaylists()
    
    return PlaylistSelection(spotifyController: spotifyController, musicKitController: MusicKitController(), source: .spotify)
}
