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

    let playlist: SpotifyPlaylist
    let playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject]
    
    @State private var progress: Double = 0
    
    @State var matchedPlaylist: [MatchedSongs] = []
    @State var selectedSongs: [Song] = []
    
    @State var creatingPlaylist: Bool = false
    @State var showAlert: Bool = false
    @State var playlistCreationMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if (progress == 1.0) {
                    List(matchedPlaylist, id: \.spotifySong.id) { matchedSongs in
                        SpotifySyncedTracks(matchedSongs: matchedSongs, selectedSongs: $selectedSongs)
                    }
                    
                    Button {
                        creatingPlaylist = true
                        Task {
                            playlistCreationMessage = await musicKit.createPlaylist(playlistName: playlist.name, songs: selectedSongs)
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
            for track in playlistItems {
                let matchedSongs = await musicKit.searchSongWithISRC(spotifyTrack: track)
                matchedPlaylist.append(matchedSongs)
                
                if let song = matchedSongs.musicKitSongs.first {
                    selectedSongs.append(song.song)
                }
                
                progress = Double(matchedPlaylist.count) / Double(playlistItems.count)
            }
            
            matchedPlaylist.sort { a, b in
                return a.maxConfidence < b.maxConfidence
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
        SpotifySyncSheet(playlist: SpotifyPlaylist(collaborative: false, description: "", external_urls: ExternalURLs(spotify: ""), followers: Followers(total: 0), href: "", id: "", images: [], name: "", owner: Owner(external_urls: ExternalURLs(spotify: ""), href: "", id: "", type: "", uri: ""), public: false, snapshot_id: "", tracks: SpotifyPlaylist.Tracks(href: "", limit: 0, offset: 0, total: 0, items: []), type: "", uri: ""), playlistItems: [])
            .environment(MusicKitController())
    })
}
