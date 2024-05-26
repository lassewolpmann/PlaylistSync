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

    var playlist: SpotifyPlaylist?
    
    @State private var progress = 0.0
    @State var matchedPlaylist: [[Song]] = []
    @State var selectedSongs: [Song] = []
    
    @State var creatingPlaylist: Bool = false
    @State var showAlert: Bool = false
    @State var playlistCreationMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if let playlist {
                    if (progress == 1.0) {
                        List {
                            ForEach(Array(matchedPlaylist.enumerated()), id: \.offset) { index, matchedSongs in
                                SpotifySyncedTracks(spotifyTrack: playlist.tracks.items[index].track, matchedSongs: matchedSongs, selectedSongs: $selectedSongs)
                            }
                        }
                        
                        Button {
                            creatingPlaylist = true
                            Task {
                                playlistCreationMessage = await musicKit.createPlaylist(playlistName: playlist.name, songs: selectedSongs)
                                creatingPlaylist = false
                                showAlert = true
                            }
                        } label: {
                            if (playlist.tracks.items.count != selectedSongs.count) {
                                Label {
                                    Text("Scroll to bottom to confirm matched Songs.")
                                        .fontWeight(.bold)
                                } icon: {
                                    Image(systemName: "exclamationmark.triangle")
                                }
                                .symbolRenderingMode(.multicolor)
                            } else {
                                Label {
                                    Text("Add synced Playlist to Apple Music")
                                        .fontWeight(.bold)
                                } icon: {
                                    Image("AppleMusicIcon")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        }
                        .frame(height: 25)
                        .labelStyle(HorizontalAlignedLabel())
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .disabled(playlist.tracks.items.count != selectedSongs.count)
                        .alert(
                            playlistCreationMessage,
                            isPresented: $showAlert
                        ) {
                            Button("OK") { showAlert.toggle() }
                        }
                        
                    } else {
                        ProgressView(value: progress) {
                            Text("Matched \(matchedPlaylist.count) out of \(playlist.tracks.items.count)")
                        }
                        .padding()
                    }
                } else {
                    Text("No Spotify Playlist selected")
                }
            }
            .navigationTitle("Matched Songs")
        }
        .task {
            if let playlist {
                for track in playlist.tracks.items {
                    let matchedSongs = await musicKit.searchSongWithISRC(spotifyTrack: track.track)
                    matchedPlaylist.append(matchedSongs)
                    progress = Double(matchedPlaylist.count) / Double(playlist.tracks.items.count)
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
                .background(.ultraThinMaterial)
            }
        }
    }
}

#Preview {
    VStack {
        
    }.sheet(isPresented: .constant(true), content: {
        SpotifySyncSheet()
            .environment(MusicKitController())
    })
}
