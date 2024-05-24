//
//  MusicKit.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation
import MusicKit

@Observable
class MusicKitController {
    var authSuccess: Bool = false
    
    func authorize() async -> Void {
        let auth = await MusicAuthorization.request()
        authSuccess = auth == .authorized
    }

    func getUserPlaylists() async -> MusicItemCollection<Playlist> {
        let request = MusicLibraryRequest<Playlist>()
        
        do {
            let playlists = try await request.response()
            return playlists.items
        } catch {
            print(error)
            return [] as MusicItemCollection<Playlist>
        }
    }
    
    func getPlaylist(playlist: Playlist?) async -> Playlist? {
        if let playlist {
            do {
                let detailedPlaylist = try await playlist.with(.tracks)

                return detailedPlaylist
                
            } catch {
                print(error)
                
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getSong(track: MusicItemCollection<Track>.Element?) async -> Song? {
        // print(track?.debugDescription)
        
        if let trackTitle = track?.title {
            var request = MusicCatalogSearchRequest(term: trackTitle, types: [Song.self])
            request.limit = 10
            
            do {
                let response = try await request.response()
                let filtered = response.songs.filter { song in
                    return song.duration == track?.duration
                }
                
                if let song = filtered.first {
                    return song
                }
            } catch {
                print(error)
                
                return nil
            }
        }
        
        return nil
    }
}
