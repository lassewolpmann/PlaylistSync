//
//  MusicKitMatchedSongs.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI
import MusicKit

struct MusicKitMatchedSongs: View {
    let matchedSongs: [SyncToMusicKit.MatchedSongs.MatchedSong]
    
    @State var selectedSong: Song?
    @Binding var selectedSongs: [Song?]
    
    var body: some View {
        NavigationLink {
            List(matchedSongs, id: \.self.song, selection: $selectedSong) { matchedSong in
                let name = matchedSong.song.title
                let artist = matchedSong.song.artistName
                let imageURL = matchedSong.song.artwork?.url(width: 640, height: 640)?.absoluteString ?? ""
                
                ItemLabel(name: name, author: artist, imageURL: imageURL)
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        selectedSong = nil
                    } label: {
                        Label {
                            Text("Ignore Match")
                        } icon: {
                            Image(systemName: "waveform.slash")
                        }
                    }
                }
            }
            .navigationTitle("Alternatives")
        } label: {
            if let song = selectedSong {
                let name = song.title
                let artist = song.artistName
                let imageURL = song.artwork?.url(width: 640, height: 640)?.absoluteString ?? ""
                
                ItemLabel(name: name, author: artist, imageURL: imageURL)
            } else {
                Label {
                    Text("Not matching this song.")
                } icon: {
                    Image(systemName: "waveform.slash")
                }
                .foregroundStyle(.red)
            }
        }.onChange(of: selectedSong) { oldValue, newValue in
            if let index = selectedSongs.firstIndex(of: oldValue) {
                selectedSongs.remove(at: index)
                selectedSongs.append(newValue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            MusicKitMatchedSongs(matchedSongs: [], selectedSongs: .constant([]))
        }
        .navigationTitle("Alternatives")
    }
}
