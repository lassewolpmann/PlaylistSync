//
//  SpotifySyncedTrack.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 26.5.2024.
//

import SwiftUI
import MusicKit

struct SpotifySyncedTracks: View {
    let spotifyTrack: SpotifyPlaylist.Tracks.Track.TrackObject
    let matchedSongs: [Song]
    
    @State private var selectedSong: Song?
    @Binding var selectedSongs: [Song]
    
    var body: some View {
        Section {
            HStack(alignment: .center) {
                Image("SpotifyIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .padding(.trailing, 10)
                
                ItemLabel(
                    name: spotifyTrack.name,
                    author: spotifyTrack.artists.first?.name ?? "",
                    imageURL: spotifyTrack.album.images.first?.url ?? ""
                )
            }
            
            if (selectedSong != nil) {
                NavigationLink {
                    List(matchedSongs, id: \.self, selection: $selectedSong) { song in
                        ItemLabel(
                            name: song.title,
                            author: song.artistName,
                            imageURL: song.artwork?.url(width: 150, height: 150)?.absoluteString ?? ""
                        )
                        
                    }
                    .navigationTitle("Select Alternative")
                } label: {
                    HStack(alignment: .center) {
                        Image("AppleMusicIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 25)
                            .padding(.trailing, 10)

                        ItemLabel(
                            name: selectedSong?.title ?? "",
                            author: selectedSong?.artistName ?? "",
                            imageURL: selectedSong?.artwork?.url(width: 150, height: 150)?.absoluteString ?? ""
                        )
                    }
                }
            } else {
                Text("Could not find this song in Apple Music")
            }
        }
        .onAppear {
            if let firstSong = matchedSongs.first {
                if (selectedSong == nil) {
                    // Only do it when no song is selected yet
                    selectedSong = firstSong
                }
            }
        }
        .onChange(of: selectedSong) { oldValue, newValue in
            if let oldValue {
                let index = selectedSongs.firstIndex(of: oldValue)
                if let index {
                    selectedSongs.remove(at: index)
                }
            }
            
            if let newValue {
                selectedSongs.append(newValue)
            }
            
            print(selectedSongs.count)
        }
    }
}

#Preview {
    List {
        SpotifySyncedTracks(spotifyTrack: SpotifyPlaylist.Tracks.Track.TrackObject(), matchedSongs: [], selectedSongs: .constant([]))
    }
}
