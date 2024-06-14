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
            .navigationTitle("Alternatives")
        } label: {
            let name = selectedSong?.title ?? ""
            let artist = selectedSong?.artistName ?? ""
            let imageURL = selectedSong?.artwork?.url(width: 640, height: 640)?.absoluteString ?? ""
            
            ItemLabel(name: name, author: artist, imageURL: imageURL)
        }.onAppear {
            if selectedSong == nil {
                if let song = matchedSongs.first?.song {
                    selectedSong = song
                }
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
    MusicKitMatchedSongs(matchedSongs: [], selectedSongs: .constant([]))
}
