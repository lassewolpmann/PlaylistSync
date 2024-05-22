//
//  ContentView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import SwiftUI
import MusicKit
import AuthenticationServices

struct ContentView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @State var tracks: MusicItemCollection<Track> = []
    
    let musicKit = MusicKitController()
    let spotify = SpotifyController()
    
    var body: some View {
        VStack {
            Button {
                Task {
                    if (musicKit.isAuthorized()) {
                        tracks = await musicKit.getAllPlaylists()
                    } else {
                        let _ = await musicKit.authorize();
                    }
                }
            } label: {
                Text("Get all Playlists")
            }
            
            Button {
                Task {
                    let url = try spotify.generateRequestURL()
                    let urlWithCode = try await webAuthenticationSession.authenticate(using: url!, callbackURLScheme: "playlistsync")
                    
                    try await spotify.exchangeCodeForToken(urlWithCode: urlWithCode)
                }
            } label: {
                Text("Authorize with Spotify")
            }
            
            Text("Tracks")
            List {
                ForEach(tracks) { track in
                    Text("\(track.title) by \(track.artistName)")
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
