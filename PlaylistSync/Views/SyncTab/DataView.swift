//
//  DataView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 12.6.2024.
//

import SwiftUI

struct DataView: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    @Binding var selectedSource: Service
    @Binding var selectedTarget: Service
    
    var body: some View {
        Section {
            Picker(selection: $selectedSource) {
                Text("Spotify").tag(Service.spotify)
                Text("Apple Music").tag(Service.appleMusic)
            } label: {
                Label {
                    Text("Source")
                } icon: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            
            Picker(selection: $selectedTarget) {
                Text("Spotify").tag(Service.spotify)
                Text("Apple Music").tag(Service.appleMusic)
            } label: {
                Label {
                    Text("Target")
                } icon: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            NavigationLink {
                switch selectedSource {
                case .spotify:
                    if (spotifyController.authSuccess) {
                        SpotifyPlaylists(spotifyController: spotifyController)
                    } else {
                        Label {
                            Text("Authorize Spotify Access before choosing a Playlist!")
                                .font(.headline)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .symbolRenderingMode(.multicolor)
                        .labelStyle(HorizontalAlignedLabel())
                        .padding()
                    }
                case .appleMusic:
                    if (musicKitController.authSuccess) {
                        MusicKitPlaylists(musicKitController: musicKitController)
                    } else {
                        Label {
                            Text("Authorize Apple Music Access before choosing a Playlist!")
                                .font(.headline)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .symbolRenderingMode(.multicolor)
                        .labelStyle(HorizontalAlignedLabel())
                        .padding()
                    }
                }
            } label: {
                Label {
                    Text("Choose Playlist")
                } icon: {
                    switch selectedSource {
                    case .spotify:
                        Image("SpotifyIcon")
                            .resizable()
                            .scaledToFit()
                    case .appleMusic:
                        Image("AppleMusicIcon")
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        } header: {
            Text("Data")
        }
    }
}

#Preview {
    List {
        DataView(spotifyController: SpotifyController(), musicKitController: MusicKitController(), selectedSource: .constant(Service.spotify), selectedTarget: .constant(Service.appleMusic))
    }
}
