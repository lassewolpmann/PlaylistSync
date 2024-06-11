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
    let selectedSongs: [Song?]
    
    @State private var showAlert = false
    @State private var playlistCreationMessage = ""
    @State private var existingPlaylist = false

    @Binding var creatingPlaylist: Bool
    
    var body: some View {
        Button {
            creatingPlaylist = true
            
            // TODO: Update playlist if it exists already. Method is already created in musicKit Class
            Task {
                playlistCreationMessage = await musicKit.createPlaylist(playlistName: playlistName, songs: selectedSongs)
                creatingPlaylist = false
                showAlert = true
            }
        } label: {
            Label {
                if (existingPlaylist) {
                    Text("Update Playlist in Apple Music")
                } else {
                    Text("Add Playlist to Apple Music")
                }
            } icon: {
                Image("AppleMusicIcon")
                    .resizable()
                    .scaledToFit()
            }
            .fontWeight(.bold)
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
        .task {
            do {
                let request = MusicLibrarySearchRequest(term: playlistName, types: [Playlist.self])
                let existingPlaylistsWithSameName = try await request.response()
                if (existingPlaylistsWithSameName.playlists.count > 0) { existingPlaylist = true }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SpotifyCreatePlaylistButton(playlistName: "", selectedSongs: [], creatingPlaylist: .constant(false))
        .environment(MusicKitController())
}
