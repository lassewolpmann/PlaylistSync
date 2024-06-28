//
//  SyncSheet.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI

struct SyncSheet: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    var syncController: SyncController
    
    @State var sourceData: [CommonSongData]?
    @State var playlistName: String = "Playlist"
    
    var body: some View {
        NavigationStack {
            if let sourceData {
                switch syncController.selectedTarget {
                case .spotify:
                    SyncToSpotify()
                        .navigationTitle(playlistName)
                case .appleMusic:
                    SyncToMusicKit(musicKitController: musicKitController, syncController: syncController, sourceData: sourceData, playlistName: playlistName)
                        .navigationTitle(playlistName)
                }
            } else {
                ProgressView {
                    Text("Loading data")
                }
            }
        }
        .task {
            // Load tracks from selected Source and store them as CommonSongData
            switch syncController.selectedSource {
            case .spotify:
                if let selectedPlaylist = spotifyController.selectedPlaylist {
                    do {
                        sourceData = try await spotifyController.createCommonData(playlist: selectedPlaylist)
                        playlistName = spotifyController.selectedPlaylist?.name ?? "Playlist"
                    } catch {
                        print(error)
                    }
                }
            case .appleMusic:
                if let selectedPlaylist = musicKitController.selectedPlaylist {
                    do {
                        sourceData = try await musicKitController.createCommonData(playlist: selectedPlaylist)
                        playlistName = musicKitController.selectedPlaylist?.name ?? "Playlist"
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    let musicKitController = MusicKitController()
    let previewSongData = CommonSongData()
    
    return SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, syncController: SyncController(), sourceData: [previewSongData])
}
