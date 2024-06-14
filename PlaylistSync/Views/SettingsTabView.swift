//
//  SettingsView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 23.5.2024.
//

import SwiftUI
import AuthenticationServices

struct SettingsTabView: View {
    @Bindable var spotifyController: SpotifyController
    @Bindable var musicKitController: MusicKitController
    
    @State private var spotifyAuthInProgress = false
    @State private var musicKitAuthInProgress = false
    
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $spotifyAuthInProgress) {
                        Label {
                            Text("Spotify")
                        } icon: {
                            Image("SpotifyIcon")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    Toggle(isOn: $musicKitAuthInProgress) {
                        Label {
                            Text("Apple Music")
                        } icon: {
                            Image("AppleMusicIcon")
                                .resizable()
                                .scaledToFit()
                        }
                        
                    }
                }
                .onChange(of: spotifyAuthInProgress) { oldValue, newValue in
                    if (newValue == true) {
                        Task {
                            if let url = try spotifyController.generateRequestURL() {
                                do {
                                    let urlWithCode = try await webAuthenticationSession.authenticate(using: url, callbackURLScheme: "playlistsync")
                                    try await spotifyController.exchangeCodeForToken(urlWithCode: urlWithCode)
                                } catch {
                                    spotifyController.reset()
                                    spotifyAuthInProgress = false
                                }
                            } else {
                                spotifyController.reset()
                                spotifyAuthInProgress = false
                            }
                        }
                    } else {
                        spotifyController.reset()
                    }
                }
                .onChange(of: musicKitAuthInProgress) { oldValue, newValue in
                    if (newValue == true) {
                        Task {
                            let _ = await musicKitController.authorize();
                        }
                    } else {
                        musicKitController.reset()
                    }
                }
            }
            .navigationTitle("Authorization")
        }
    }
}

#Preview {
    SettingsTabView(spotifyController: SpotifyController(), musicKitController: MusicKitController())
}
