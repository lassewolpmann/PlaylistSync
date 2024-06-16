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
            .fill(.tertiary)
            .aspectRatio(1.0, contentMode: .fit)
            .containerRelativeFrame(.horizontal)
            .overlay {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: url ?? "")) { image in
                        image
                            .resizable()
                            .blur(radius: 10.0)
                            .clipped()
                    } placeholder: {
                        ProgressView {
                            Text("Loading Image")
                        }
                    }
                    
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .clear, location: 0),
                            Gradient.Stop(color: .primary, location: 0.8)
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
                        
                        Button {
                            if let spotifyPlaylist {
                                spotifyController.selectedPlaylist = spotifyPlaylist
                            } else if let musicKitPlaylist {
                                musicKitController.selectedPlaylist = musicKitPlaylist
                            }
                        } label: {
                            if let spotifyPlaylist {
                                Label {
                                    Text(spotifyPlaylist == spotifyController.selectedPlaylist ? "Selected" : "Select")
                                        .bold()
                                } icon: {
                                    Image(systemName: spotifyPlaylist == spotifyController.selectedPlaylist ? "checkmark.circle" : "circle")
                                }
                            } else if let musicKitPlaylist {
                                Label {
                                    Text(musicKitPlaylist == musicKitController.selectedPlaylist ? "Selected" : "Select")
                                        .bold()
                                } icon: {
                                    Image(systemName: musicKitPlaylist == musicKitController.selectedPlaylist ? "checkmark.circle" : "circle")
                                }
                            }
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
