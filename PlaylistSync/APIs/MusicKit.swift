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
        guard let trackTitle = track?.title else {
            return nil
        }
        
        guard let trackArtist = track?.artistName.lowercased() else {
            return nil
        }
        
        guard let trackDuration = track?.duration else {
            return nil
        }
        
        var request = MusicCatalogSearchRequest(term: "\(trackTitle) \(trackArtist)", types: [Song.self])
        request.limit = 25
        
        do {
            let response = try await request.response()
            let filtered = response.songs.filter { song in
                return song.duration == trackDuration && song.artistName.lowercased() == trackArtist
            }
            
            guard let song = filtered.first else {
                print("Could not find \(trackTitle), by \(trackArtist)", response.debugDescription)
                
                return nil
            }
            
            return song
        } catch {
            print(error)
            
            return nil
        }
    }
    
    func searchSongWithISRC(spotifyTrack: SpotifyPlaylist.Tracks.Track.TrackObject) async -> [Song] {
        struct MatchedSong {
            var song: Song
            var confidence: Int
        }
        
        var spotifyTrackName = spotifyTrack.name.lowercased()
        
        // Replace fuck with f**k, since Apple Music doesn't allow that word
        if (spotifyTrackName.contains("fuck")) {
            spotifyTrackName = spotifyTrackName.replacingOccurrences(of: "fuck", with: "f**k")
        }
        var request = MusicCatalogSearchRequest(term: "\(spotifyTrackName) \(spotifyTrack.artists.first?.name.lowercased() ?? "")", types: [Song.self])
        request.limit = 25

        var matchedSongs: [MatchedSong] = []
        
        do {
            let tracks = try await request.response()
            
            for song in tracks.songs {
                let confidence = calculateConfidence(spotifyTrack: spotifyTrack, musicKitTrack: song)
                matchedSongs.append(MatchedSong(song: song, confidence: confidence))
            }
            
            matchedSongs = matchedSongs.sorted(by: { a, b in
                a.confidence > b.confidence
            })
            
            let confidenceSortedsongs = matchedSongs.map { $0.song }
            
            return confidenceSortedsongs
        } catch {
            return []
        }
    }
}
