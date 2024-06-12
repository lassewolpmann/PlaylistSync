//
//  MusicKit.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation
import MusicKit
import Vision

@Observable class MusicKitController {
    var authSuccess: Bool = false
    
    var playlistToSync: Playlist?
    var commonSongData: [CommonSongData]?
    var loadingCommonData = false
    
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
        do {
            let library = MusicLibrary.shared
            try await library.createPlaylist(name: playlistName, description: "Created by PlaylistSync", items: songs.compactMap { $0 }) // This removes all nil values
            
            return "Successfully created Playlist in your Library."
        } catch {
            return "Could not create Playlist: \(error.localizedDescription)."
        }
    }
    
    func updatedPlaylist(playlist: Playlist, songs: [Song?]) async -> String {
        do {
            let library = MusicLibrary.shared
            try await library.edit(playlist, items: songs.compactMap { $0 })
            
            return "Successfully updated Playlist."
        } catch {
            return "Could not update Playlist: \(error.localizedDescription)."
        }
    }
    
    func createCommonData() async throws -> Void {
        if let playlist = await self.getPlaylist(playlist: self.playlistToSync) {
            if let items = playlist.tracks {
                var detailedItems: [Song] = []
                
                for item in items {
                    switch item {
                    case .song(let song):
                        let detailedSong = try await song.with(.albums)
                        
                        detailedItems.append(detailedSong)
                    case .musicVideo:
                        print("Ignoring Music Videos")
                    }
                }
                
                let commonSongData = detailedItems.map { item in
                    let duration_in_ms = Int(item.duration ?? 0) * 1000
                    let album = item.albums?.first
                    let album_artwork = album?.artwork?.url(width: 640, height: 640)
                    
                    return CommonSongData(name: item.title, disc_number: item.discNumber ?? 0, track_number: item.trackNumber ?? 0, artist_name: item.artistName, isrc: item.isrc ?? "Unknown ISRC", duration_in_ms: duration_in_ms, album_name: item.albumTitle ?? "Unknown Album", album_release_date: album?.releaseDate, album_artwork_cover: album_artwork, album_artwork_width: 640, album_artwork_height: 640)
                }
                                
                self.commonSongData = commonSongData
            } else {
                throw MusicKitError.resourceError("Could not create Common Data")
            }
        } else {
            throw MusicKitError.resourceError("Could not create Common Data")
        }
    }
}
