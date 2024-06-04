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
    
    if (spotifyTrack.disc_number == musicKitTrack.discNumber) { confidence += 2 }
    
    if (spotifyTrack.track_number == musicKitTrack.trackNumber) { confidence += 3 }
    
    if (spotifyTrack.album.name == musicKitTrack.albumTitle) { confidence += 4 }
    
    let spotifyArtistName = spotifyTrack.artists.first?.name.lowercased()
    let musicKitArtistName = musicKitTrack.artistName.lowercased()
    if (spotifyArtistName == musicKitArtistName) { confidence += 5 }
    
    if (spotifyTrack.external_ids.isrc == musicKitTrack.isrc) { confidence += 6 }
    
    let spotifySongDuration = floor(Double(spotifyTrack.duration_ms) / 1000)
    let musicKitSongDuration = floor(musicKitTrack.duration ?? 0.0)
    if (spotifySongDuration == musicKitSongDuration) { confidence += 7 }
    
    let spotifyReleaseDate = spotifyTrack.album.release_date
    let musicKitReleaseDate = musicKitTrack.releaseDate
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    if let date = formatter.date(from: spotifyReleaseDate) {
        let spotifyTimeInterval = date.timeIntervalSince1970
        let musicKitTimeInterval = musicKitReleaseDate?.timeIntervalSince1970
        
        if (spotifyTimeInterval == musicKitTimeInterval) { confidence += 8 }
    }
    
    // TODO: Include Shazam Kit
    let spotifyPreviewURL = spotifyTrack.preview_url
    let musicKitPreviewURL = musicKitTrack.previewAssets?.first?.url
    
    return confidence
}

func calculateRemainingTime(matchingTime: [Double], remainingSongs: Int) -> Double {
    let totalTime = matchingTime.reduce(0, +)
    let averageTime = totalTime / Double(matchingTime.count)
    
    return averageTime * Double(remainingSongs)
}
