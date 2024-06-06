//
//  SpotifySyncedTrack.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 26.5.2024.
//

import SwiftUI
import MusicKit

struct SpotifySyncedTracks: View {
    let matchedSongs: MatchedSongs
    
    @State private var selectedSong: Song?
    @Binding var selectedSongs: [Song?]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\((matchedSongs.maxConfidencePct), specifier: "%.0f")% Matching Confidence")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
            
            HStack(alignment: .center) {
                ItemLabel(
                    name: matchedSongs.spotifySong.name,
                    author: matchedSongs.spotifySong.artists.first?.name ?? "",
                    imageURL: matchedSongs.spotifySong.album.images.first?.url ?? ""
                )
                
                Spacer()
                
                Image("SpotifyIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
            }
            
            if (selectedSong != nil) {
                NavigationLink {
                    List(matchedSongs.musicKitSongs, id: \.self.song, selection: $selectedSong) { matched in
                        ItemLabel(
                            name: matched.song.title,
                            author: matched.song.artistName,
                            imageURL: matched.song.artwork?.url(width: 150, height: 150)?.absoluteString ?? ""
                        )
                    }
                    .navigationTitle("Select Alternative")
                } label: {
                    HStack(alignment: .center) {
                        ItemLabel(
                            name: selectedSong?.title ?? "",
                            author: selectedSong?.artistName ?? "",
                            imageURL: selectedSong?.artwork?.url(width: 150, height: 150)?.absoluteString ?? ""
                        )
                        
                        Spacer()
                        
                        Image("AppleMusicIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 25)
                    }
                }
            } else {
                HStack(alignment: .center) {
                    Label {
                        Text("Could not find this song in Apple Music.")
                            .bold()
                    } icon: {
                        Image(systemName: "x.circle")
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(.red)
                    }
                    .labelStyle(HorizontalAlignedLabel())
                    
                    Spacer()
                    
                    Image("AppleMusicIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 25)
                }
            }
        }
        .onAppear {
            // Set first matched song as selected song
            if let firstSong = matchedSongs.musicKitSongs.first {
                if (selectedSong == nil) {
                    selectedSong = firstSong.song
                }
            }
        }
        .onChange(of: selectedSong) { oldValue, newValue in
            if let oldValue {
                let index = selectedSongs.firstIndex(of: oldValue)
                if let index {
                    selectedSongs.remove(at: index)
                    
                    if let newValue {
                        selectedSongs.insert(newValue, at: index)
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        SpotifySyncedTracks(matchedSongs: MatchedSongs(musicKitSongs: [], spotifySong: SpotifyPlaylist.Tracks.Track.TrackObject(album: SpotifyPlaylist.Tracks.Track.TrackObject.Album(album_type: "", total_tracks: 0, images: [], name: "", release_date: ""), artists: [], disc_number: 0, duration_ms: 0, explicit: false, external_ids: SpotifyPlaylist.Tracks.Track.TrackObject.ExternalIDs(), id: "", name: "", track_number: 0), maxConfidence: 0, maxConfidencePct: 0), selectedSongs: .constant([]))
    }
}
