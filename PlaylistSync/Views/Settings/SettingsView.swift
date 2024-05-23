//
//  SettingsView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 23.5.2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SpotifyController.self) private var spotify
    @Environment(MusicKitController.self) private var musicKit
    
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    
    @State var spotifyAuth: Bool = false
    @State var musicKitAuth: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $spotifyAuth) {
                        Text("Spotify")
                    }
                    
                    Toggle(isOn: $musicKitAuth) {
                        Text("MusicKit")
                    }
                } header: {
                    Text("Authorization")
                }
                .onAppear {
                    spotifyAuth = spotify.authSuccess
                    musicKitAuth = musicKit.authSuccess
                }
                .onChange(of: spotifyAuth) { oldValue, newValue in
                    if (newValue == true) {
                        Task {
                            let url = try spotify.generateRequestURL()
                            let urlWithCode = try await webAuthenticationSession.authenticate(using: url!, callbackURLScheme: "playlistsync")
                            
                            try await spotify.exchangeCodeForToken(urlWithCode: urlWithCode)
                        }
                    } else {
                        spotify.revokeToken()
                    }
                }
                .onChange(of: musicKitAuth) { oldValue, newValue in
                    if (newValue == true) {
                        Task {
                            let _ = await musicKit.authorize();
                        }
                    } else {
                        print("Revoke MusicKit auth")
                    }
                }
                
                Section {
                    
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(SpotifyController())
        .environment(MusicKitController())
}
