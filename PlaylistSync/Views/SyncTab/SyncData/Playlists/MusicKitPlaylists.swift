//
//  MusicKitPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI
import MusicKit

struct MusicKitPlaylists: View {
    @Bindable var musicKitController: MusicKitController
    let playlists: MusicItemCollection<Playlist>
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                ForEach(playlists, id: \.self) { playlist in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomLeading) {
                            PlaylistSelectionImage(url: playlist.artwork?.url(width: 1024, height: 1024)?.absoluteString ?? "")
                        
                            VStack(alignment: .leading) {
                                Text(playlist.name)
                                    .font(.headline)
                                
                                if let creator = playlist.curatorName {
                                    Text(creator)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Button {
                                    musicKitController.selectedPlaylist = playlist
                                } label: {
                                    if (musicKitController.selectedPlaylist == playlist) {
                                        Label {
                                            Text("Selected")
                                        } icon: {
                                            Image(systemName: "checkmark.circle")
                                        }
                                    } else {
                                        Label {
                                            Text("Select")
                                        } icon: {
                                            Image(systemName: "circle")
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .padding()
                        }
                        .containerRelativeFrame(.horizontal)
                        .clipShape(.rect(cornerRadius: 32))
                    }
                    .scrollTransition(
                        axis: .horizontal
                    ) { content, phase in
                        content
                            .opacity(1 - (abs(phase.value) * 0.8))
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 32)
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    MusicKitPlaylists(musicKitController: MusicKitController(), playlists: [])
}
