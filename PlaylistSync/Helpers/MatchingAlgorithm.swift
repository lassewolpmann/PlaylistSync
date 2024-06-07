//
//  MatchingAlgorithm.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import Foundation
import MusicKit
import Vision

func calculateConfidence(spotifyTrack: SpotifyPlaylist.Tracks.Track.TrackObject, musicKitTrack: Song, advancedMatching: Bool, spotifyFeaturePrint: VNFeaturePrintObservation?) -> Int {
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
     
    // Spotify has different precisions for the album release date. Therefore I need to check the precision first before setting the right format for the date formatter.
    let formatter = DateFormatter()
    let spotifyReleaseDatePrecision = spotifyTrack.album.release_date_precision
    
    if (spotifyReleaseDatePrecision == "year") {
        formatter.dateFormat = "yyyy"
    } else if (spotifyReleaseDatePrecision == "month") {
        formatter.dateFormat = "yyyy-MM"
    } else if (spotifyReleaseDatePrecision == "day") {
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    let spotifyReleaseDate = spotifyTrack.album.release_date
    let musicKitReleaseDate = musicKitTrack.releaseDate
    
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    if let date = formatter.date(from: spotifyReleaseDate), let musicKitReleaseDate {
        if (date == musicKitReleaseDate) { confidence += 8 }
    }
    
    /*
    // TODO: Include Shazam Kit
    let spotifyPreviewURL = spotifyTrack.preview_url
    let musicKitPreviewURL = musicKitTrack.previewAssets?.first?.url
     */

    // Thanks to this article: https://medium.com/@MWM.io/apples-vision-framework-exploring-advanced-image-similarity-techniques-f7bb7d008763
    if (advancedMatching) {
        if let spotifyAlbumCover = spotifyTrack.album.images.first {
            guard let height = spotifyAlbumCover.height else { return confidence }
            guard let width = spotifyAlbumCover.width else { return confidence }
            
            guard let musicKitAlbumCoverURL = musicKitTrack.artwork?.url(width: height, height: width) else { return confidence }
            
            if let musicKitFeaturePrint = featurePrintForImage(imageURL: musicKitAlbumCoverURL), let spotifyFeaturePrint {
                var distance: Float = 0
                try? spotifyFeaturePrint.computeDistance(&distance, to: musicKitFeaturePrint)
                
                if (distance < 0.4) { confidence += 9 }
            }
        }
    }
    
    return confidence
}

func calculateRemainingTime(matchingTime: [Double], remainingSongs: Int) -> Double {
    let totalTime = matchingTime.reduce(0, +)
    let averageTime = totalTime / Double(matchingTime.count)
    
    return averageTime * Double(remainingSongs)
}

func featurePrintForImage(imageURL: URL) -> VNFeaturePrintObservation? {
    let requestHandler = VNImageRequestHandler(url: imageURL, orientation: .up, options: [:])
    
    do {
        let request = VNGenerateImageFeaturePrintRequest()
        try requestHandler.perform([request])
        return request.results?.first as? VNFeaturePrintObservation
    } catch {
        return nil
    }
}
