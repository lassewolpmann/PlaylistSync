//
//  MusicKit.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import Foundation
import MusicKit

func authorize() async -> MusicAuthorization.Status {
    return await MusicAuthorization.request()
}

func isAuthorized() -> Bool {
    return MusicAuthorization.currentStatus == .authorized
}

func getAllPlaylists() async -> Void {
    do {
        let libraryPlaylistsURL = URL(string: "https://api.music.apple.com/v1/me/library/playlists")!
        let libraryPlaylistsRequest = MusicDataRequest(urlRequest: URLRequest(url: libraryPlaylistsURL))
        let libraryPlaylistsResponse = try await libraryPlaylistsRequest.response()
        
        let decoder = JSONDecoder()
        let libraryPlaylists = try decoder.decode(MusicItemCollection<Playlist>.self, from: libraryPlaylistsResponse.data)

        if let libraryPlaylist = libraryPlaylists.first {
            let detailedLibraryPlaylist = try await libraryPlaylist.with([.tracks])
            let tracks = detailedLibraryPlaylist.tracks ?? []
            print("\(tracks)")
        }
    } catch {
        
    }
}
