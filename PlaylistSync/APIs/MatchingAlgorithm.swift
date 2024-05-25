//
//  MatchingAlgorithm.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import Foundation
import MusicKit

func calculateConfidence(spotifyTrack: SpotifyPlaylist.Tracks.Track.TrackObject, musicKitTrack: Song) -> Int {
    var confidence = 0

    if (spotifyTrack.name == musicKitTrack.title) { confidence += 1 }
    
    let spotifySongDuration = floor(Double(spotifyTrack.duration_ms) / 1000)
    let musicKitSongDuration = floor(musicKitTrack.duration ?? 0.0)
    if (spotifySongDuration == musicKitSongDuration) { confidence += 2 }
    
    let spotifyArtistName = spotifyTrack.artists.first?.name.lowercased()
    let musicKitArtistName = musicKitTrack.artistName.lowercased()
    if (spotifyArtistName == musicKitArtistName) { confidence += 3 }
    
    if (spotifyTrack.album.name == musicKitTrack.albumTitle) { confidence += 4 }
    
    if (spotifyTrack.disc_number == musicKitTrack.discNumber) { confidence += 5 }
    
    if (spotifyTrack.track_number == musicKitTrack.trackNumber) { confidence += 6 }
    
    let spotifyReleaseDate = spotifyTrack.album.release_date
    let musicKitReleaseDate = musicKitTrack.releaseDate?.ISO8601Format().components(separatedBy: "T").first
    if (spotifyReleaseDate == musicKitReleaseDate) { confidence += 7 }
    
    return confidence
}
