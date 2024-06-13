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
    
    var selectedSource: Service
    var selectedTarget: Service
    
    var matchingLimit: Double
    var useAdvancedMatching: Bool
    
    @State var loadingItems = true
    @State var matchingItems = true
    
    @State var sourceData: [CommonSongData] = []
    @State var matchedData: [MatchedSongs] = []
    
    @State var playlistName: String = ""
    
    var body: some View {
        NavigationStack {
            if (loadingItems || matchingItems) {
                List {
                    Label {
                        Text("Loading Songs")
                    } icon: {
                        if (loadingItems) {
                            ProgressView()
                        } else {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                    
                    Label {
                        Text("Matching Songs")
                    } icon: {
                        if (matchingItems) {
                            ProgressView()
                        } else {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                }
                .task {
                    do {
                        sourceData = try await getSourceData()
                        loadingItems = false
                        
                        matchedData = await getMatchedSongs()
                        matchingItems = false
                    } catch {
                        print(error)
                    }
                }
            } else {
                List(matchedData, id: \.self) { data in
                    Section {
                        ItemLabel(name: data.sourceSong.name, author: data.sourceSong.artist_name, imageURL: data.sourceSong.album_artwork_cover?.absoluteString ?? "")
                        
                        NavigationLink {
                            List(data.targetSongs, id: \.self.song) { target in
                                ItemLabel(name: target.song.name, author: target.song.artist_name, imageURL: target.song.album_artwork_cover?.absoluteString ?? "")
                            }
                            .navigationTitle("Alternatives")
                        } label: {
                            let firstSong = data.targetSongs.first
                            let name = firstSong?.song.name ?? ""
                            let artist = firstSong?.song.artist_name ?? ""
                            let imageURL = firstSong?.song.album_artwork_cover?.absoluteString ?? ""
                            
                            ItemLabel(name: name, author: artist, imageURL: imageURL)
                        }
                    } header: {
                        Text("\((data.maxConfidencePct), specifier: "%.0f")% Matching Confidence")
                    }
                    
                }
                .navigationTitle(playlistName)
            }
        }
    }
    
    func getSourceData() async throws -> [CommonSongData] {
        print("Getting Source Data")
        switch selectedSource {
        case .spotify:
            playlistName = spotifyController.playlistToSync?.name ?? "Playlist"
            try await spotifyController.createCommonData()
            
            if let items = spotifyController.commonSongData {
                return items
            } else {
                return []
            }
        case .appleMusic:
            playlistName = musicKitController.playlistToSync?.name ?? "Playlist"
            try await musicKitController.createCommonData()
            
            if let items = musicKitController.commonSongData {
                return items
            } else {
                return []
            }
        }
    }
    
    func getMatchedSongs() async -> [MatchedSongs] {
        switch selectedTarget {
        case .spotify:
            // Search Spotify API
            print("Search in Spotify")
            
            return []
        case .appleMusic:
            // Search MusicKit
            print("Search in Apple Music")
            do {
                var data: [MatchedSongs] = []
                
                for item in sourceData {
                    let matchedItem = try await musicKitController.matchSong(searchObject: item, searchLimit: matchingLimit, useAdvancedMatching: useAdvancedMatching)
                    data.append(matchedItem)
                }
                
                data = data.sorted(by: { a, b in
                    return a.maxConfidence < b.maxConfidence
                })
                
                return data
            } catch {
                print(error)
                
                return []
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
        SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, selectedSource: Service.spotify, selectedTarget: Service.appleMusic, matchingLimit: 5.0, useAdvancedMatching: true)
    }
}
