//
//  SpotifyAuthButton.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI

struct SpotifyAuthButton: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @Environment(SpotifyController.self) private var spotify
    
    var body: some View {
        Button {
            Task {
                let url = try spotify.generateRequestURL()
                let urlWithCode = try await webAuthenticationSession.authenticate(using: url!, callbackURLScheme: "playlistsync")
                
                try await spotify.exchangeCodeForToken(urlWithCode: urlWithCode)
            }
        } label: {
            Text("Authorize with Spotify")
        }
    }
}

#Preview {
    SpotifyAuthButton()
}
