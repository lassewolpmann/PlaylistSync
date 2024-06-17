//
//  PlaylistSelectionImage.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI
import MusicKit

struct PlaylistSelectionImage: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var spotifyController: SpotifyController
    @Bindable var musicKitController: MusicKitController

    var spotifyPlaylist: UserPlaylists.Playlist?
    var musicKitPlaylist: Playlist?
    
    @State var url: String?
    @State var name: String?
    @State var author: String?
    
    var body: some View {
        Rectangle()
            .aspectRatio(1.0, contentMode: .fit)
            .containerRelativeFrame(.horizontal)
            .overlay {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: url ?? "")) { image in
                        image
                            .resizable()
                            .clipped()
                    } placeholder: {
                        ProgressView {
                            Text("Loading Image")
                        }
                    }
                    
                    Rectangle()
                        .fill(.regularMaterial)
                        .mask {
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: .clear, location: 0),
                                    Gradient.Stop(color: .primary, location: 0.75)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text(name ?? "")
                                .font(.headline)
                            
                            if let author {
                                Text(author)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let playlist = spotifyPlaylist {
                            Button {
                                if (spotifyController.selectedPlaylist == playlist) {
                                    spotifyController.selectedPlaylist = nil
                                } else {
                                    spotifyController.selectedPlaylist = playlist
                                }
                            } label: {
                                if (playlist == spotifyController.selectedPlaylist) {
                                    Label {
                                        Text("Selected")
                                    } icon: {
                                        Image(systemName: "checkmark.circle")
                                    }
                                    .foregroundStyle(.green)
                                } else {
                                    Label {
                                        Text("Select")
                                    } icon: {
                                        Image(systemName: "circle")
                                    }
                                }
                            }.bold()
                        } else if let playlist = musicKitPlaylist {
                            Button {
                                if (musicKitController.selectedPlaylist == playlist) {
                                    musicKitController.selectedPlaylist = nil
                                } else {
                                    musicKitController.selectedPlaylist = playlist
                                }
                            } label: {
                                if (playlist == musicKitController.selectedPlaylist) {
                                    Label {
                                        Text("Selected")
                                    } icon: {
                                        Image(systemName: "checkmark.circle")
                                    }
                                    .foregroundStyle(.green)
                                } else {
                                    Label {
                                        Text("Select")
                                    } icon: {
                                        Image(systemName: "circle")
                                    }
                                }
                            }.bold()
                        }
                    }
                    .padding()
                }
            }
            .clipShape(.rect(cornerRadius: 30))
            .onAppear {
                if let spotifyPlaylist {
                    url = spotifyPlaylist.images.first?.url
                    name = spotifyPlaylist.name
                    author = spotifyPlaylist.owner.display_name
                } else if let musicKitPlaylist {
                    url = musicKitPlaylist.artwork?.url(width: 1024, height: 1024)?.absoluteString
                    name = musicKitPlaylist.name
                    author = musicKitPlaylist.curatorName
                }
            }
    }
}

#Preview {
    let playlist = UserPlaylists.Playlist()
    
    return PlaylistSelectionImage(spotifyController: SpotifyController(), musicKitController: MusicKitController(), spotifyPlaylist: playlist)
}
