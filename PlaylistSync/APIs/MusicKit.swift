//
//  MusicKit.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation
import MusicKit

class MusicKitController {
    func authorize() async -> MusicAuthorization.Status {
        return await MusicAuthorization.request()
    }

    func isAuthorized() -> Bool {
        return MusicAuthorization.currentStatus == .authorized
    }
    
    func getAllPlaylists() async -> MusicItemCollection<Playlist> {
        do {
            let libraryPlaylistsURL = URL(string: "https://api.music.apple.com/v1/me/library/playlists")!
            let libraryPlaylistsRequest = MusicDataRequest(urlRequest: URLRequest(url: libraryPlaylistsURL))
            let libraryPlaylistsResponse = try await libraryPlaylistsRequest.response()
            
            let decoder = JSONDecoder()
            let libraryPlaylists = try decoder.decode(MusicItemCollection<Playlist>.self, from: libraryPlaylistsResponse.data)

            return libraryPlaylists
        } catch {
            print("Error")
        }
        
        return [] as MusicItemCollection<Playlist>
    }
}
