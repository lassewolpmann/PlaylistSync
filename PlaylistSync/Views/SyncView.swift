//
//  SyncView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import SwiftUI

enum Service: String, Identifiable {
    case spotify, appleMusic
    var id: Self { self }
}

struct SyncView: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    @State var selectedSource: Service = .spotify
    @State var selectedTarget: Service = .appleMusic
    
    @State var playlistPlaceholder: String = "Playlist Title"
    @State var customPlaylistName: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label {
                        HStack {
                            Text("Spotify")
                            Spacer()
                            Image("SpotifyIcon")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(height: 30)
                    } icon: {
                        Image(systemName: spotifyController.authSuccess ? "checkmark" : "xmark")
                    }
                    
                    Label {
                        HStack {
                            Text("Apple Music")
                            Spacer()
                            Image("AppleMusicIcon")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(height: 30)
                    } icon: {
                        Image(systemName: musicKitController.authSuccess ? "checkmark" : "xmark")
                    }
                } header: {
                    Text("Auth Status")
                }
                .symbolRenderingMode(.multicolor)
                
                Section {
                    Picker("Source", selection: $selectedSource) {
                        Text("Spotify").tag(Service.spotify)
                        Text("Apple Music").tag(Service.appleMusic)
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
                        .frame(height: 30)
                    }
                    
                    Picker("Target", selection: $selectedTarget) {
                        Text("Spotify").tag(Service.spotify)
                        Text("Apple Music").tag(Service.appleMusic)
                    }
                    
                    HStack {
                        switch selectedTarget {
                        case .spotify:
                            Image("SpotifyIcon")
                                .resizable()
                                .scaledToFit()
                        case .appleMusic:
                            Image("AppleMusicIcon")
                                .resizable()
                                .scaledToFit()
                        }
                        
                        TextField(
                            playlistPlaceholder,
                            text: $customPlaylistName
                        )
                        .padding(.leading)
                    }
                    .frame(height: 30)
                }
                
                switch selectedSource {
                case .spotify:
                    if let playlist = spotifyController.playlistToSync {
                        ItemLabel(
                            name: playlist.name,
                            author: playlist.owner.display_name ?? "",
                            imageURL: playlist.images.first?.url ?? ""
                        )
                    }
                case .appleMusic:
                    if let playlist = musicKitController.playlistToSync {
                        ItemLabel(
                            name: playlist.name,
                            author: playlist.curatorName ?? "",
                            imageURL: playlist.artwork?.url(width: 50, height: 50)?.absoluteString ?? ""
                        )
                    }
                }
                
                Button {
                    print("Test")
                } label: {
                    switch selectedTarget {
                    case .spotify:
                        Label("Sync Playlist to Spotify", systemImage: "arrow.triangle.2.circlepath")
                            .font(.headline)
                    case .appleMusic:
                        Label("Sync Playlist to Apple Music", systemImage: "arrow.triangle.2.circlepath")
                            .font(.headline)
                    }
                }
                .disabled(checkForDisabledButton())
            }
            .navigationTitle("Sync")
        }
        .onChange(of: spotifyController.playlistToSync) { old, new in
            if let playlist = new {
                playlistPlaceholder = playlist.name
            }
        }
        .onChange(of: musicKitController.playlistToSync) { old, new in
            if let playlist = new {
                playlistPlaceholder = playlist.name
            }
        }
    }
    
    func checkForDisabledButton() -> Bool {
        var sourceDisabled = true
        var targetDisabled = true
        var sameSourceAndTarget = true
        
        switch selectedSource {
        case .spotify:
            sourceDisabled = !spotifyController.authSuccess
        case .appleMusic:
            sourceDisabled = !musicKitController.authSuccess
        }
        
        switch selectedTarget {
        case .spotify:
            targetDisabled = !spotifyController.authSuccess
        case .appleMusic:
            targetDisabled = !musicKitController.authSuccess
        }
        
        sameSourceAndTarget = selectedSource == selectedTarget
        
        if (sourceDisabled || targetDisabled || sameSourceAndTarget ) {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    let musicKitController = MusicKitController()
    
    spotifyController.authSuccess = false
    musicKitController.authSuccess = false
    
    return SyncView(spotifyController: spotifyController, musicKitController: musicKitController)
}
