//
//  MusicKit.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation
import MusicKit

struct MatchedSong: Hashable {
    var song: Song
    var confidence: Int
}

struct MatchedSongs: Hashable {
    static func == (lhs: MatchedSongs, rhs: MatchedSongs) -> Bool {
        return lhs.spotifySong.id == rhs.spotifySong.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(spotifySong.id)
    }
    
    var musicKitSongs: [MatchedSong]
    var spotifySong: SpotifyPlaylist.Tracks.Track.TrackObject
    var maxConfidence: Int
    var maxConfidencePct: Double
}

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
    
    func searchSongWithISRC(spotifyTrack: SpotifyPlaylist.Tracks.Track.TrackObject) async -> MatchedSongs {
        var spotifyTrackName = spotifyTrack.name.lowercased()
        
        // Replace fuck with f**k, since Apple Music doesn't allow that word
        if (spotifyTrackName.contains("fuck")) {
            spotifyTrackName = spotifyTrackName.replacingOccurrences(of: "fuck", with: "f**k")
        }
        
        if (spotifyTrackName.contains("`")) {
            spotifyTrackName = spotifyTrackName.replacingOccurrences(of: "`", with: "'")
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
            
            guard let maxConfidence = matchedSongs.first?.confidence else { return MatchedSongs(musicKitSongs: [], spotifySong: spotifyTrack, maxConfidence: 0, maxConfidencePct: 0) }
            
            // 36 is highest possible confidence score
            let maxConfidencePct = (Double(maxConfidence) / 36) * 100
            
            return MatchedSongs(musicKitSongs: matchedSongs, spotifySong: spotifyTrack, maxConfidence: maxConfidence, maxConfidencePct: maxConfidencePct)
        } catch {
            return MatchedSongs(musicKitSongs: [], spotifySong: spotifyTrack, maxConfidence: 0, maxConfidencePct: 0)
        }
    }
    
    func createPlaylist(playlistName: String, songs: [Song]) async -> String {
        let request = MusicLibrarySearchRequest(term: playlistName, types: [Playlist.self])
        
        do {
            let existingPlaylistsWithSameName = try await request.response()
            if (existingPlaylistsWithSameName.playlists.count > 0) { return "Playlist with same name exists already." }
        } catch {
            return "Could not check for existing Playlists in Apple Music Library: \(error.localizedDescription)."
        }
        
        do {
            let library = MusicLibrary.shared

            try await library.createPlaylist(name: playlistName, description: "Created by PlaylistSync", items: songs)
            
            return "Successfully created Playlist in your Library."
        } catch {
            return "Could not create Playlist: \(error.localizedDescription)."
        }
    }
}
