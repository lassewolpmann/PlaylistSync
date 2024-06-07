//
//  MusicKit.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation
import MusicKit
import Vision

enum MusicKitError: Error {
    case matchingError(String)
    case resourceError(String)
    case artworkError(String)
}

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
    
    var musicKitSongs: [MatchedSong] = []
    var spotifySong: SpotifyPlaylist.Tracks.Track.TrackObject
    var maxConfidence: Int = 0
    var maxConfidencePct: Double = 0.0
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
    
    func searchSongWithISRC(spotifyTrack: SpotifyPlaylist.Tracks.Track.TrackObject, limit: Double, advancedMatching: Bool) async throws -> MatchedSongs {
        // Split name at "-" and "(", since they usually add information that might confuse the Apple Music Search
        var name = spotifyTrack.name.components(separatedBy: "-").first ?? spotifyTrack.name
        name = name.components(separatedBy: "(").first ?? name
        name = name.replacingOccurrences(of: "`", with: "'")
        name = name.replacingOccurrences(of: "fuck", with: "f**k", options: .caseInsensitive)
        name = name.trimmingCharacters(in: .whitespaces)
        
        // Only taking the first artist should be enough and avoids confusion when listing multiple artists
        let artist = spotifyTrack.artists.first?.name ?? ""
                
        var request = MusicCatalogSearchRequest(term: "\(name) \(artist)", types: [Song.self])
        request.limit = Int(limit)
        
        // Create feature print for Spotify Artwork
        var spotifyFeaturePrint: VNFeaturePrintObservation?
        if (advancedMatching) {
            if let spotifyAlbumCover = spotifyTrack.album.images.first {
                guard let spotifyAlbumCoverURL = URL(string: spotifyAlbumCover.url) else { throw MusicKitError.artworkError("Could not get URL for Spotify Album Artwork") }
                spotifyFeaturePrint = featurePrintForImage(imageURL: spotifyAlbumCoverURL)
            }
            
        }
        
        do {
            let result = try await request.response()
            
            let songs = result.songs
            let matchedSongs = songs.map { song in
                let confidence = calculateConfidence(spotifyTrack: spotifyTrack, musicKitTrack: song, advancedMatching: advancedMatching, spotifyFeaturePrint: spotifyFeaturePrint)
                return MatchedSong(song: song, confidence: confidence)
            }.sorted(by: { a, b in
                a.confidence > b.confidence
            })
            
            guard let maxConfidence = matchedSongs.first?.confidence else { throw MusicKitError.matchingError("Could not match song") }
            
            // 45 is highest possible confidence score
            let maxConfidencePct = advancedMatching ? (Double(maxConfidence) / 45) * 100 : (Double(maxConfidence) / 36) * 100
            
            return MatchedSongs(musicKitSongs: matchedSongs, spotifySong: spotifyTrack, maxConfidence: maxConfidence, maxConfidencePct: maxConfidencePct)
        } catch {
            throw MusicKitError.resourceError("Could not find song \(spotifyTrack.name) \(spotifyTrack.artists.first?.name ?? "")")
        }
    }
    
    func createPlaylist(playlistName: String, songs: [Song?]) async -> String {
        let request = MusicLibrarySearchRequest(term: playlistName, types: [Playlist.self])
        
        do {
            let existingPlaylistsWithSameName = try await request.response()
            if (existingPlaylistsWithSameName.playlists.count > 0) { return "Playlist with same name exists already." }
        } catch {
            return "Could not check for existing Playlists in Apple Music Library: \(error.localizedDescription)."
        }
        
        do {
            let library = MusicLibrary.shared

            try await library.createPlaylist(name: playlistName, description: "Created by PlaylistSync", items: songs.compactMap { $0 }) // This removes all nil values
            
            return "Successfully created Playlist in your Library."
        } catch {
            return "Could not create Playlist: \(error.localizedDescription)."
        }
    }
}
