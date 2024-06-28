//
//  PlaylistSelectionImage.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI
import MusicKit

struct PlaylistArtwork: View {
    @Environment(\.colorScheme) private var colorScheme

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
                    
                    VStack(alignment: .leading) {
                        Text(name ?? "")
                            .font(.headline)
                        
                        if let author {
                            Text(author)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .clipShape(.rect(cornerRadius: 10))
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
    
    return PlaylistArtwork(spotifyPlaylist: playlist)
}
