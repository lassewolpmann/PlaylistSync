//
//  MatchingAlgorithm.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import Foundation
import MusicKit
import Vision

func calculateConfidence(sourceData: CommonSongData, targetData: CommonSongData, useAdvancedMatching: Bool, sourceFeaturePrint: VNFeaturePrintObservation?) -> Int {
    var confidence = 0
    
    if (sourceData.name == targetData.name) { confidence += 1 }
    
    if (sourceData.disc_number == targetData.disc_number) { confidence += 2 }
    
    if (sourceData.track_number == targetData.track_number) { confidence += 3 }
    
    if (sourceData.album_name == targetData.album_name) { confidence += 4 }
    
    if (sourceData.artist_name == targetData.artist_name) { confidence += 5 }
     
    if (sourceData.isrc == targetData.isrc) { confidence += 6 }
    
    if (sourceData.duration_in_ms == targetData.duration_in_ms) { confidence += 7 }
     
    if (sourceData.album_release_date == targetData.album_release_date) { confidence += 8 }
    
    /*
    // TODO: Include Shazam Kit
    let spotifyPreviewURL = spotifyTrack.preview_url
    let musicKitPreviewURL = musicKitTrack.previewAssets?.first?.url
     */

    // Thanks to this article: https://medium.com/@MWM.io/apples-vision-framework-exploring-advanced-image-similarity-techniques-f7bb7d008763
    if (useAdvancedMatching) {
        if (sourceData.album_artwork_height == targetData.album_artwork_height && sourceData.album_artwork_width == targetData.album_artwork_width) {
            if let albumURL = targetData.album_artwork_cover {
                if let targetFeaturePrint = featurePrintForImage(imageURL: albumURL), let sourceFeaturePrint {
                    var distance: Float = 0
                    try? sourceFeaturePrint.computeDistance(&distance, to: targetFeaturePrint)
                    
                    if (distance < 0.4) { confidence += 9 }
                }
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

struct MatchedSong: Hashable, Identifiable {
    var song: CommonSongData
    var confidence: Int
    
    var id: String {
        song.isrc
    }
}

struct MatchedSongs: Hashable {
    static func == (lhs: MatchedSongs, rhs: MatchedSongs) -> Bool {
        return lhs.sourceSong.isrc == rhs.sourceSong.isrc
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sourceSong.isrc)
    }
    
    var targetSongs: [MatchedSong] = []
    var sourceSong: CommonSongData
    var maxConfidence: Int = 0
    var maxConfidencePct: Double = 0.0
}
