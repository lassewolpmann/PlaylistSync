//
//  SpotifyView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI
import AuthenticationServices

struct SpotifyView: View {
    @Environment(SpotifyController.self) private var spotify
    @Environment(MusicKitController.self) private var musicKit
    
    @State var selection = Set<UserPlaylists.Playlist>()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if (spotify.authSuccess) {
                    SpotifyPlaylists(selection: $selection)
                        .environment(spotify)
                } else {
                    Text("Authorize Spotify in Settings.")
                }
                
                if (selection.count > 0) {
                    SpotifySyncButton(playlists: selection)
                }
            }
            .navigationTitle("Spotify")
            .toolbar {
                EditButton()
            }
        }
    }
}

#Preview {
    TabView {
        let playlist = UserPlaylists.Playlist(collaborative: true, description: "Preview Playlist", external_urls: ExternalURLs(spotify: ""), href: "", id: "", images: [], name: "Preview Playlist", owner: Owner(external_urls: ExternalURLs(spotify: ""), href: "", id: "", type: "", uri: ""), public: true, snapshot_id: "", tracks: UserPlaylists.Playlist.Tracks(href: "", total: 5), type: "", uri: "")
        let controller = SpotifyController()
        
        SpotifyView(selection: [playlist])
            .tabItem {
                Label("Spotify", systemImage: "music.note")
            }
            .environment(controller)
            .environment(MusicKitController())
            .onAppear {
                controller.authSuccess = true
            }
    }
}
