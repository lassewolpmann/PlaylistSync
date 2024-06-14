//
//  SyncToMusicKit.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI
import MusicKit

struct SyncToMusicKit: View {
    struct MatchedSongs: Hashable {
        static func == (lhs: SyncToMusicKit.MatchedSongs, rhs: SyncToMusicKit.MatchedSongs) -> Bool {
            return lhs.sourceData == rhs.sourceData
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(sourceData)
        }
        
        struct MatchedSong: Hashable {
            let song: Song
            let confidence: Int
        }
        
        let sourceData: CommonSongData
        let matchedData: [MatchedSong]
        let maxConfidence: Int
        let maxConfidencePct: Double
    }
    
    var musicKitController: MusicKitController
    @Bindable var syncController: SyncController
    
    let sourceData: [CommonSongData]
    @State var playlistName: String
    
    @State var matchedData: [MatchedSongs]?
    @State var selectedSongs: [Song?] = []
    
    var body: some View {
        if let matchedData {
            List {
                Section {
                    TextField(text: $playlistName) {
                        Text("Playlist Name")
                    }
                    Button {
                        syncController.addingPlaylist = true
                        Task {
                            let _ = await musicKitController.createPlaylist(playlistName: playlistName, songs: selectedSongs)
                            syncController.addingPlaylist = false
                        }
                    } label: {
                        Label {
                            Text("Add \(playlistName) to Apple Music")
                        } icon: {
                            Image("AppleMusicIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                        }
                        .labelStyle(HorizontalAlignedLabel())
                    }
                }
                
                
                ForEach(matchedData, id: \.self) { data in
                    let originalData = data.sourceData
                    
                    Section {
                        ItemLabel(name: originalData.name, author: originalData.artist_name, imageURL: originalData.album_artwork_cover?.absoluteString ?? "")
                        
                        MusicKitMatchedSongs(matchedSongs: data.matchedData, selectedSongs: $selectedSongs)
                    } header: {
                        Text("\((data.maxConfidencePct), specifier: "%.0f")% Matching Confidence")
                    }
                }
            }
        } else {
            ProgressView {
                Text("Matching Playlist")
            }.task {
                var data: [MatchedSongs] = []
                
                for song in sourceData {
                    do {
                        let matchedSongs = try await musicKitController.matchSong(searchObject: song, searchLimit: syncController.syncMatchingLimit, useAdvancedMatching: syncController.useAdvancedSync)
                        data.append(matchedSongs)
                        selectedSongs.append(matchedSongs.matchedData.first!.song)
                    } catch {
                        data.append(MatchedSongs(sourceData: song, matchedData: [], maxConfidence: 0, maxConfidencePct: 0))
                        selectedSongs.append(nil)
                    }
                }
                
                matchedData = data.sorted(by: { a, b in
                    a.maxConfidence < b.maxConfidence
                })
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        SyncToMusicKit(musicKitController: MusicKitController(), syncController: SyncController(), sourceData: [], playlistName: "Preview Playlist", matchedData: [SyncToMusicKit.MatchedSongs(sourceData: CommonSongData(), matchedData: [], maxConfidence: 0, maxConfidencePct: 0), SyncToMusicKit.MatchedSongs(sourceData: CommonSongData(), matchedData: [], maxConfidence: 0, maxConfidencePct: 0), SyncToMusicKit.MatchedSongs(sourceData: CommonSongData(), matchedData: [], maxConfidence: 0, maxConfidencePct: 0), SyncToMusicKit.MatchedSongs(sourceData: CommonSongData(), matchedData: [], maxConfidence: 0, maxConfidencePct: 0)])
            .navigationTitle("Preview Playlist")
    }
}
