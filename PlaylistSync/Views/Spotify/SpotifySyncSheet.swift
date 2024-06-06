//
//  SpotifySyncSheet.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import SwiftUI
import MusicKit

struct SpotifySyncSheet: View {
    @Environment(MusicKitController.self) private var musicKit

    let spotifyPlaylistName: String
    let spotifyPlaylistItems: [SpotifyPlaylist.Tracks.Track.TrackObject]
    let matchingLimit: Double
    let useAdvancedMatching: Bool
    
    @State private var progress: Double = 0
    @State private var eta: Double = 0
    
    @State var selectedSongs: [Song?] = []
    @State private var matchedPlaylist: [MatchedSongs] = []
    
    @State var creatingPlaylist: Bool = false
    
    var body: some View {
        NavigationStack {
            if (progress == 1.0) {
                VStack {
                    List {
                        ForEach(matchedPlaylist, id: \.self) { matchedSongs in
                            Section {
                                SpotifySyncedTracks(matchedSongs: matchedSongs, selectedSongs: $selectedSongs)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            matchedPlaylist.remove(atOffsets: indexSet)
                            selectedSongs.remove(atOffsets: indexSet)
                        })
                    }
                    .toolbar {
                        EditButton()
                    }
                    
                    SpotifyCreatePlaylistButton(playlistName: spotifyPlaylistName, selectedSongs: selectedSongs, creatingPlaylist: $creatingPlaylist)
                        .environment(musicKit)
                }
                .navigationTitle("Matched Songs")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ProgressView(value: progress) {
                        Text("Matched \(matchedPlaylist.count) out of \(spotifyPlaylistItems.count)")
                    }
                    
                    Text("Estimated time remaining: \(Int(eta)) \(Int(eta) == 1 ? "second" : "seconds")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .navigationTitle("Matching \(spotifyPlaylistName)")
            }
        }
        .labelStyle(HorizontalAlignedLabel())
        .task {
            var matchingTime: [Double] = []
            
            // Step 1: Try to match Spotify Song with Apple Music Search
            for spotifyTrack in spotifyPlaylistItems {
                do {
                    let startingTimestamp = Date().timeIntervalSince1970
                    let matchedSongs = try await musicKit.searchSongWithISRC(spotifyTrack: spotifyTrack, limit: matchingLimit, advancedMatching: useAdvancedMatching)
                    let endingTimestamp = Date().timeIntervalSince1970
                    
                    matchingTime.append(endingTimestamp - startingTimestamp)
                                                    
                    matchedPlaylist.append(matchedSongs)
                    progress = Double(matchedPlaylist.count) / Double(spotifyPlaylistItems.count)
                    eta = calculateRemainingTime(matchingTime: matchingTime, remainingSongs: spotifyPlaylistItems.count - matchedPlaylist.count)
                } catch {
                    matchedPlaylist.append(MatchedSongs(spotifySong: spotifyTrack))
                    print(error)
                }
                
            }
            
            // Step 2: Sort by lowest confidence first
            matchedPlaylist.sort { a, b in
                return a.maxConfidence < b.maxConfidence
            }
            
            // Step 3: Go through matchedPlaylist and add first matched song from Apple Music to selectedSongs
            matchedPlaylist.forEach { matchedSongs in
                if let song = matchedSongs.musicKitSongs.first {
                    selectedSongs.append(song.song)
                } else {
                    selectedSongs.append(nil)
                }
            }
        }
        .disabled(creatingPlaylist)
        .overlay {
            if (creatingPlaylist) {
                VStack {
                    Text("Creating Playlist...")
                    ProgressView()
                }
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    VStack {
        
    }.sheet(isPresented: .constant(true), content: {
        SpotifySyncSheet(spotifyPlaylistName: SpotifyPlaylist().name, spotifyPlaylistItems: [SpotifyPlaylist.Tracks.Track.TrackObject()], matchingLimit: 5.0, useAdvancedMatching: false)
            .environment(MusicKitController())
    })
}
