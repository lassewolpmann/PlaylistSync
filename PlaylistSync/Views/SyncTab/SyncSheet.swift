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
    
    @State var playlistName = ""
    
    var body: some View {
        NavigationStack {
            if let sourceData = syncController.sourceData {
                if let targetData = syncController.targetData {
                    switch targetData {
                    case .spotify(let matchedData):
                        Text("Spotify")
                            .navigationTitle(playlistName)
                    case .appleMusic(let matchedData):
                        List(matchedData, id: \.sourceData.isrc) { data in
                            Section {
                                let sourceArtworkURL = data.sourceData.album_artwork_cover?.absoluteString ?? ""
                                ItemLabel(name: data.sourceData.name, author: data.sourceData.artist_name, imageURL: sourceArtworkURL)
                                
                                if let firstSong = data.matchedData.first?.song {
                                    NavigationLink {
                                        List(data.matchedData, id: \.song.self) { data in
                                            let artworkURL = data.song.artwork?.url(width: 640, height: 640)?.absoluteString ?? ""
                                            ItemLabel(name: data.song.title, author: data.song.artistName, imageURL: artworkURL)
                                        }
                                        .navigationTitle("Alternatives")
                                    } label: {
                                        let selectedArtworkURL = firstSong.artwork?.url(width: 640, height: 640)?.absoluteString ?? ""
                                        ItemLabel(name: firstSong.title, author: firstSong.artistName, imageURL: selectedArtworkURL)
                                    }
                                }
                            }
                        }
                        .navigationTitle(playlistName)
                    }
                } else {
                    ProgressView {
                        Text("Matching Songs...")
                    }
                    .task {
                        switch syncController.selectedSource {
                        case .spotify:
                            playlistName = spotifyController.playlistToSync?.name ?? ""
                        case .appleMusic:
                            playlistName = musicKitController.playlistToSync?.name ?? ""
                        }
                        
                        switch syncController.selectedTarget {
                        case .spotify:
                            // Match to Spotify
                            print("Spotify")
                        case .appleMusic:
                            // Match to Apple Music
                            print("Apple Music")
                            do {
                                var data: [MusicKitMatchedSongs] = []
                                
                                for item in sourceData {
                                    let matchedItem = try await musicKitController.matchSong(searchObject: item, searchLimit: syncController.syncMatchingLimit, useAdvancedMatching: syncController.useAdvancedSync)
                                    data.append(matchedItem)
                                }
                                
                                data = data.sorted(by: { a, b in
                                    return a.maxConfidence < b.maxConfidence
                                })
                                
                                syncController.targetData = .appleMusic(data)
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            } else {
                ProgressView {
                    Text("Loading Playlist data...")
                }.task {
                    do {
                        switch syncController.selectedSource {
                        case .spotify:
                            try await spotifyController.createCommonData()
                            if let data = spotifyController.commonSongData {
                                syncController.sourceData = data
                            }
                        case .appleMusic:
                            try await musicKitController.createCommonData()
                            if let data = musicKitController.commonSongData {
                                syncController.sourceData = data
                            }
                        }
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
    let previewSongData = CommonSongData(name: "Preview Song", disc_number: 0, track_number: 0, artist_name: "Preview Artist", isrc: "", duration_in_ms: 1, album_name: "Preview Album", album_artwork_cover: URL(string: "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228"))
    
    spotifyController.commonSongData = [previewSongData, previewSongData, previewSongData]
    
    return VStack {
        Text("Preview")
    }.sheet(isPresented: .constant(true)) {
        SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, syncController: SyncController())
    }
}
