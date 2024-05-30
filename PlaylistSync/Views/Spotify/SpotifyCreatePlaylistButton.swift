//
//  SpotifyCreatePlaylistButton.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 30.5.2024.
//

import SwiftUI
import MusicKit

struct SpotifyCreatePlaylistButton: View {
    @Environment(MusicKitController.self) private var musicKit

    let playlistName: String
    let selectedSongs: [Song]
    
    @State private var showAlert: Bool = false
    @State private var playlistCreationMessage: String = ""
    
    @Binding var creatingPlaylist: Bool
    
    var body: some View {
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
        .alert(
            playlistCreationMessage,
            isPresented: $showAlert
        ) {
            Button("OK") { showAlert.toggle() }
        }
    }
}

#Preview {
    SpotifyCreatePlaylistButton(playlistName: "", selectedSongs: [], creatingPlaylist: .constant(false))
        .environment(MusicKitController())
}
