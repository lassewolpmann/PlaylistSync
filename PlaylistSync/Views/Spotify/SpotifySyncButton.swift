//
//  SpotifySyncButton.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import SwiftUI

struct SpotifySyncButton: View {
    @Environment(SpotifyController.self) private var spotify
    @Environment(MusicKitController.self) private var musicKit
    
    @State var showSheet: Bool = false
    
    let playlistName: String
    let playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject]
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label {
                Text("Sync \(playlistName) to Apple Music")
                    .fontWeight(.bold)
            } icon: {
                Image("AppleMusicIcon")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 25)
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
        .background(.ultraThinMaterial, in:
                        RoundedRectangle(cornerRadius: 10)
        )
        .padding(.bottom, 10)
        .sheet(isPresented: $showSheet, content: {
            SpotifySyncSheet(playlistName: playlistName, playlistItems: playlistItems)
                .environment(musicKit)
                .presentationBackground(.ultraThinMaterial)
        })
    }
}

#Preview {
    SpotifySyncButton(playlistName: SpotifyPlaylist().name, playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject()])
        .environment(SpotifyController())
        .environment(MusicKitController())
}
