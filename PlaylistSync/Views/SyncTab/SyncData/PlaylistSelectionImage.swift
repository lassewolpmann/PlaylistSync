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
        let cornerRadius = 15.0
        Rectangle()
            .fill(.thinMaterial)
            .aspectRatio(1.0, contentMode: .fit)
            .containerRelativeFrame(.horizontal)
            .overlay {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: url ?? "")) { image in
                        image
                            .resizable()
                            .clipped()
                            .blur(radius: 3)
                    } placeholder: {
                        ProgressView {
                            Text("Loading Image")
                        }
                    }
                    
                    LinearGradient(
                        colors: [
                            .secondary.opacity(0),
                            .secondary.opacity(0.7),
                            .primary.opacity(1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
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
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        
                        Spacer()
                        
                        if let playlist = spotifyPlaylist {
                            Button {
                                spotifyController.selectedPlaylist = playlist
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
                                musicKitController.selectedPlaylist = playlist
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
            .clipShape(.rect(cornerRadius: cornerRadius))
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
