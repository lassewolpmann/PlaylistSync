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
        var selectedSong: Song?
        let maxConfidence: Int
        let maxConfidencePct: Double
    }
    
    var musicKitController: MusicKitController
    @Bindable var syncController: SyncController
    
    let sourceData: [CommonSongData]
    @State var playlistName: String
    
    @State var matchedData: [MatchedSongs] = []
    @State var selectedSongs: [Song?] = []
    
    @State var dataLoaded = false
    @State var eta: Double = 0
    
    var body: some View {
        if (dataLoaded) {
            List {
                Section {
                    TextField(text: $playlistName) {
                        Text("Playlist Name")
                    }
                    Button {
                        syncController.addingPlaylist = true
                        Task {
                            let alertMessage = await musicKitController.createPlaylist(playlistName: playlistName, songs: selectedSongs)
                            print(alertMessage)
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
                        
                        MusicKitMatchedSongs(matchedSongs: data.matchedData, selectedSong: data.selectedSong, selectedSongs: $selectedSongs)
                    } header: {
                        Text("\((data.maxConfidencePct), specifier: "%.0f")% Matching Confidence")
                    }
                }
            }
            .toolbar {
                EditButton()
            }
        } else {
            ProgressView(value: Double(matchedData.count), total: Double(sourceData.count)) {
                VStack(alignment: .leading) {
                    Text("Matching Songs - \(matchedData.count)/\(sourceData.count)")
                    Text("Estimated time remaining: \(Date().addingTimeInterval(eta), style: .relative)")
                }
            }
            .padding()
            .task {
                var timeIntervals: [Double] = []
                
                for song in sourceData {
                    do {
                        let startTime = Date().timeIntervalSince1970
                        let matchedSongs = try await musicKitController.matchSong(searchObject: song, searchLimit: syncController.syncMatchingLimit, useAdvancedMatching: syncController.useAdvancedSync)
                        let finishTime = Date().timeIntervalSince1970
                        
                        // Calculate ETA
                        timeIntervals.append(finishTime - startTime)
                        eta = calculateRemainingTime(matchingTime: timeIntervals, remainingSongs: sourceData.count - matchedData.count)
                        
                        // Append data to matchedData and select first song as selectedSong
                        matchedData.append(matchedSongs)
                        selectedSongs.append(matchedSongs.matchedData.first!.song)
                    } catch {
                        matchedData.append(MatchedSongs(sourceData: song, matchedData: [], maxConfidence: 0, maxConfidencePct: 0))
                        selectedSongs.append(nil)
                    }
                }
                
                matchedData = matchedData.sorted(by: { a, b in
                    a.maxConfidence < b.maxConfidence
                })
                
                dataLoaded = true
            }
        }
        
    }
}

#Preview {
    var sourceData: [CommonSongData] = []
    
    for _ in (1...3) {
        sourceData.append(CommonSongData())
    }
    
    return NavigationStack {
        SyncToMusicKit(musicKitController: MusicKitController(), syncController: SyncController(), sourceData: sourceData, playlistName: "Preview Playlist", matchedData: [])
            .navigationTitle("Preview Playlist")
    }
}
