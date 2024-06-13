//
//  SyncController.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import Foundation
import MusicKit

struct SpotifyMatchedSongs {
    struct MatchedSong {
        let song: SpotifyPlaylist.Tracks.Track.TrackObject
        let confidence: Int
    }
    
    let sourceData: CommonSongData
    let matchedData: [SpotifyMatchedSongs.MatchedSong]
    let maxConfidence: Int
    let maxConfidencePct: Double
}

struct MusicKitMatchedSongs {
    struct MatchedSong: Identifiable {
        let song: Song
        let confidence: Int
        
        var id: String {
            song.id.description
        }
    }
    
    let sourceData: CommonSongData
    let matchedData: [MusicKitMatchedSongs.MatchedSong]
    let maxConfidence: Int
    let maxConfidencePct: Double
}

enum Service: String, Identifiable {
    case spotify, appleMusic
    var id: Self { self }
}

enum TargetData {
    case spotify([SpotifyMatchedSongs])
    case appleMusic([MusicKitMatchedSongs])
}

@Observable class SyncController {
    var selectedSource: Service = .spotify
    var selectedTarget: Service = .appleMusic
    
    var syncMatchingLimit: Double = 5.0
    var useAdvancedSync: Bool = false
    
    var showSyncSheet: Bool = false
    
    var sourceData: [CommonSongData]?
    var targetData: TargetData?
}
