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
    @State var musicKitSongs: [[Song?]] = []
    @State private var progress = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if let playlist {
                    if (progress == 1.0) {
                        List {
                            ForEach(Array(musicKitSongs.enumerated()), id: \.offset) { index, matchedSongs in
                                Section {
                                    let spotifyTrack = playlist.tracks.items[index]
                                    HStack(alignment: .center) {
                                        Image("SpotifyIcon")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 25)
                                            .padding(.trailing, 10)
                                        
                                        ItemLabel(
                                            name: spotifyTrack.track.name,
                                            author: spotifyTrack.track.artists.first?.name ?? "",
                                            imageURL: spotifyTrack.track.album.images.first?.url ?? ""
                                        )
                                    }
                                    
                                    if let musicKitTrack = matchedSongs.first {
                                        NavigationLink {
                                            List(matchedSongs, id: \.?.id) { song in
                                                if let song {
                                                    ItemLabel(
                                                        name: song.title,
                                                        author: song.artistName,
                                                        imageURL: song.artwork?.url(width: 150, height: 150)?.absoluteString ?? ""
                                                    )
                                                } else {
                                                    Text("Could not find this song in Apple Music")
                                                }
                                                
                                            }
                                            .navigationTitle("Alternatives")
                                        } label: {
                                            HStack(alignment: .center) {
                                                Image("AppleMusicIcon")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 25)
                                                    .padding(.trailing, 10)

                                                ItemLabel(
                                                    name: musicKitTrack?.title ?? "",
                                                    author: musicKitTrack?.artistName ?? "",
                                                    imageURL: musicKitTrack?.artwork?.url(width: 150, height: 150)?.absoluteString ?? ""
                                                )
                                            }
                                        }
                                    } else {
                                        Text("Could not find this song in Apple Music")
                                    }
                                }
                            }
                        }
                        
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
    SpotifySyncSheet()
        .environment(MusicKitController())
}
