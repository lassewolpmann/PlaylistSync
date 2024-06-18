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
    
    var playlistOverview: MusicItemCollection<Playlist>?
    var playlistOverviewFilter: String = ""
    var selectedPlaylist: Playlist?
    
    var filteredPlaylists: [Playlist] {
        if let playlistOverview {
            return playlistOverview.filter { playlist in
                if playlistOverviewFilter != "" {
                    return playlist.name.lowercased().contains(playlistOverviewFilter.lowercased())
                } else {
                    return true
                }
            }
        } else {
            return []
        }
    }
    
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
    
    func matchSong(searchObject: CommonSongData, searchLimit: Double, useAdvancedMatching: Bool) async throws -> SyncToMusicKit.MatchedSongs {
        var request = MusicCatalogSearchRequest(term: "\(searchObject.fixedName) \(searchObject.artist_name)", types: [Song.self])
        request.limit = Int(searchLimit)
        
        // Create feature print
        var sourceFeaturePrint: VNFeaturePrintObservation?
        if (useAdvancedMatching) {
            guard let albumCoverURL = searchObject.album_artwork_cover else { throw MusicKitError.artworkError("Could not get URL for Album Artwork") }
            sourceFeaturePrint = featurePrintForImage(imageURL: albumCoverURL)
        }
        
        do {
            let result = try await request.response()
            
            let matchedSongs = result.songs.map { item in
                let duration_in_ms = Int(item.duration ?? 0) * 1000
                let artwork = item.artwork
                
                let commonSong = CommonSongData(name: item.title, disc_number: item.discNumber ?? 0, track_number: item.trackNumber ?? 0, artist_name: item.artistName, isrc: item.isrc ?? "Unknown ISRC", duration_in_ms: duration_in_ms, album_name: item.albumTitle ?? "Unknown Album", album_release_date: item.releaseDate, album_artwork_cover: artwork?.url(width: 640, height: 640), album_artwork_width: 640, album_artwork_height: 640)
                
                let confidence = calculateConfidence(sourceData: searchObject, targetData: commonSong, useAdvancedMatching: useAdvancedMatching, sourceFeaturePrint: sourceFeaturePrint)
                return SyncToMusicKit.MatchedSongs.MatchedSong(song: item, confidence: confidence)
            }.sorted(by: { a, b in
                a.confidence > b.confidence
            })
            
            guard let maxConfidence = matchedSongs.first?.confidence else { throw MusicKitError.matchingError("Could not match song") }
            
            // 45 is highest possible confidence score
            let maxConfidencePct = useAdvancedMatching ? (Double(maxConfidence) / 45) * 100 : (Double(maxConfidence) / 36) * 100
            
            return SyncToMusicKit.MatchedSongs(sourceData: searchObject, matchedData: matchedSongs, selectedSong: matchedSongs.first?.song, maxConfidence: maxConfidence, maxConfidencePct: maxConfidencePct)
        } catch {
            throw MusicKitError.matchingError("Could not match song")
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
    
    func createCommonData(playlist: Playlist) async throws -> [CommonSongData] {
        let detailedPlaylist = try await playlist.with(.tracks)
        
        if let items = detailedPlaylist.tracks {
            var detailedItems: [Song] = []
            
            for item in items {
                switch item {
                case .song(let song):
                    let detailedSong = try await song.with(.albums)
                    
                    detailedItems.append(detailedSong)
                case .musicVideo:
                    print("Ignoring Music Videos")
                @unknown default:
                    print("Unknown case")
                }
            }
            
            let commonSongData = detailedItems.map { item in
                let duration_in_ms = Int(item.duration ?? 0) * 1000
                let album = item.albums?.first
                let album_artwork = album?.artwork?.url(width: 640, height: 640)
                
                return CommonSongData(name: item.title, disc_number: item.discNumber ?? 0, track_number: item.trackNumber ?? 0, artist_name: item.artistName, isrc: item.isrc ?? "Unknown ISRC", duration_in_ms: duration_in_ms, album_name: item.albumTitle ?? "Unknown Album", album_release_date: album?.releaseDate, album_artwork_cover: album_artwork, album_artwork_width: 640, album_artwork_height: 640)
            }
                            
            return commonSongData
        } else {
            throw MusicKitError.resourceError("Could not create Common Data")
        }
    }
    
    func reset() -> Void {
        authSuccess = false
        playlistOverview = nil
        selectedPlaylist = nil
    }
}
