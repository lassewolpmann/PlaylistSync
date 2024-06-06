//
//  SpotifyPlaylistView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 23.5.2024.
//

import SwiftUI

struct SpotifyPlaylistView: View {
    @Environment(SpotifyController.self) private var spotify
    @Environment(MusicKitController.self) private var musicKit

    let playlistID: String
    
    @State var playlist: SpotifyPlaylist?
    @State var playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject]?
    
    @State var showSheet: Bool = false
    
    @State var matchingLimit = 5.0
    @State var useAdvancedMatching = false
    
    @State var showSliderInfo = false
    @State var showToggleInfo = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let playlist, let playlistItems {
                List {
                    Section {
                        HStack(spacing: 15) {
                            Slider(
                                value: $matchingLimit,
                                in: 5...25,
                                step: 1
                            ) {
                                Text("Songs to search when syncing")
                            } minimumValueLabel: {
                                Text("5")
                            } maximumValueLabel: {
                                Text("25")
                            }
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            
                            Button {
                                showSliderInfo.toggle()
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                        }
                        
                        HStack(spacing: 15) {
                            Toggle(isOn: $useAdvancedMatching) {
                                Label {
                                    Text("Advanced Sync")
                                } icon: {
                                    Image(systemName: "wand.and.stars")
                                        .foregroundStyle(.green)
                                }
                            }
                            
                            Button {
                                showToggleInfo.toggle()
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                        }
                    } header: {
                        Text("Sync Settings")
                    }
                    .sheet(isPresented: $showSliderInfo, content: {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Matching Limit")
                                .font(.title)
                            
                            Text("This settings changes the amount of songs the App searches for when trying to match the Playlist.")
                            Text("Increasing this value might return better results but also increases the amount of time the matching process will take.")
                            Text("Higher limits work better with faster network connections.").bold()
                        }
                        .padding()
                    })
                    .sheet(isPresented: $showToggleInfo, content: {
                        VStack(alignment: .leading, spacing: 15) {
                            Label {
                                Text("Advanced Sync")
                                    .font(.title)
                            } icon: {
                                Image(systemName: "wand.and.stars")
                                    .foregroundStyle(.green)
                            }
                            
                            Text("Enabling this option will enable some more advanced syncing methods like album image recognition.")
                            Text("This might return better results but also increases the amount of time the matching process will take.")
                            Text("Advanced Sync works best on newer and more capable hardware.").bold()
                        }
                        .padding()
                    })
                    
                    ForEach(playlistItems, id: \.id) { item in
                        ItemLabel(
                            name: item.name,
                            author: item.artists.first?.name ?? "",
                            imageURL: item.album.images.first?.url ?? ""
                        )
                    }
                }
                .sheet(isPresented: $showSheet, content: {
                    SpotifySyncSheet(spotifyPlaylistName: playlist.name, spotifyPlaylistItems: playlistItems, matchingLimit: matchingLimit, useAdvancedMatching: useAdvancedMatching)
                        .environment(musicKit)
                        .presentationBackground(.ultraThinMaterial)
                })
                
                SpotifySyncButton(showSheet: $showSheet, playlistName: playlist.name)
            } else {
                VStack {
                    Text("Loading Playlist")
                    ProgressView()
                }
            }
            
            
        }
        .navigationTitle(playlist?.name ?? "")
        .task {
            do {
                playlist = try await spotify.getPlaylist(playlistID: playlistID)
                
                if let playlist {
                    playlistItems = try await spotify.getPlaylistItems(url: playlist.tracks.href, total: playlist.tracks.total)
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SpotifyPlaylistView(playlistID: "3cEYpjA9oz9GiPac4AsH4n", playlist: SpotifyPlaylist(), playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject()])
            .environment(SpotifyController())
            .environment(MusicKitController())
    }
    
}
