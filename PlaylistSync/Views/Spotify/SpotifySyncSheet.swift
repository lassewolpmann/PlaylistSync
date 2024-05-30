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
    
    @State private var creatingPlaylist: Bool = false
    @State private var showAlert: Bool = false
    @State private var playlistCreationMessage: String = ""
    
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
                    
                    Button {
                        creatingPlaylist = true
                        Task {
                            playlistCreationMessage = await musicKit.createPlaylist(playlistName: playlistName, songs: selectedSongs)
                            creatingPlaylist = false
                            showAlert = true
                        }
                    } label: {
                        Label {
                            Text("Add synced Playlist to Apple Music")
                                .fontWeight(.bold)
                        } icon: {
                            Image("AppleMusicIcon")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(height: 25)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .disabled(playlistItems.count != selectedSongs.count)
                    .alert(
                        playlistCreationMessage,
                        isPresented: $showAlert
                    ) {
                        Button("OK") { showAlert.toggle() }
                    }
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
            // Step 4: Calculate progress
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
