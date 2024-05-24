//
//  SpotifyPlaylists.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI

struct SpotifyPlaylists: View {
    @Environment(SpotifyController.self) private var spotify
    @State private var playlists: UserPlaylists?

    var body: some View {
        List {
            if (playlists != nil) {
                ForEach(playlists?.items ?? [], id: \.id) { playlist in
                    NavigationLink {
                        SpotifyPlaylistView(playlistID: playlist.id)
                            .environment(spotify)
                    } label: {
                        ItemLabel(
                            name: playlist.name,
                            author: playlist.owner.display_name ?? "",
                            imageURL: playlist.images.first?.url ?? ""
                        )
                    }
                }
            } else {
                Text("Loading...")
            }
        }
        .task {
            if (playlists == nil) {
                do {
                    playlists = try await spotify.getUserPlaylists()
                } catch {
                    print(error)
                }
            }
        }
        .refreshable {
            do {
                playlists = try await spotify.getUserPlaylists()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SpotifyPlaylists()
        .environment(SpotifyController())
}
