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
    @State var musicKitSongs: [[Song]] = []
    @State private var progress = 0.0
    
    var body: some View {
        NavigationStack {
            VStack {
                if let playlist {
                    if (progress == 1.0) {
                        List {
                            Label {
                                Text("Go through the List to make sure every Song is correctly matched.")
                                    .font(.headline)
                            } icon: {
                                Image(systemName: "exclamationmark.triangle")
                            }
                            .symbolRenderingMode(.multicolor)
                            
                            ForEach(Array(musicKitSongs.enumerated()), id: \.offset) { index, matchedSongs in
                                SpotifySyncedTracks(spotifyTrack: playlist.tracks.items[index].track, matchedSongs: matchedSongs)
                            }
                        }
                        
                        Button {
                            print("Adding Playlist to Apple Music")
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
                        
                    } else {
                        ProgressView(value: progress) {
                            Text("Matched \(musicKitSongs.count) out of \(playlist.tracks.items.count)")
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
                    let song = await musicKit.searchSongWithISRC(spotifyTrack: track.track)
                    musicKitSongs.append(song)
                    progress = Double(musicKitSongs.count) / Double(playlist.tracks.items.count)
                }
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
