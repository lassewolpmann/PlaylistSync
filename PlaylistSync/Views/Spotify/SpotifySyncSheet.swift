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

    let playlistName: String
    let playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject]
    
    @State private var progress: Double = 0
    
    @State var selectedSongs: [Song] = []
    @State private var matchedPlaylist: [MatchedSongs] = []
    
    @State var creatingPlaylist: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if (progress == 1.0) {
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
                    
                    SpotifyCreatePlaylistButton(playlistName: playlistName, selectedSongs: selectedSongs, creatingPlaylist: $creatingPlaylist)
                        .disabled(matchedPlaylist.count != selectedSongs.count)
                        .environment(musicKit)
                } else {
                    ProgressView(value: progress) {
                        Text("Matched \(matchedPlaylist.count) out of \(playlistItems.count)")
                    }
                    .padding()
                }
            }
            .labelStyle(HorizontalAlignedLabel())
            .navigationTitle("Matched Songs")
        }
        .task {
            // Step 1: Try to match Spotify Song with Apple Music Search
            for track in playlistItems {
                let matchedSongs = await musicKit.searchSongWithISRC(spotifyTrack: track)
                matchedPlaylist.append(matchedSongs)
                progress = Double(matchedPlaylist.count) / Double(playlistItems.count)
            }
            
            // Step 2: Sort by lowest confidence first
            matchedPlaylist.sort { a, b in
                return a.maxConfidence < b.maxConfidence
            }
            
            // Step 3: Go through matchedPlaylist and add first matched song from Apple Music to selectedSongs
            matchedPlaylist.forEach { matchedSongs in
                if let song = matchedSongs.musicKitSongs.first {
                    selectedSongs.append(song.song)
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
        SpotifySyncSheet(playlistName: SpotifyPlaylist().name, playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject()])
            .environment(MusicKitController())
    })
}
