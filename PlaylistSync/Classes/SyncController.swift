//
//  SyncController.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import Foundation
import MusicKit

struct CommonSongData: Hashable {
    var name: String = "Preview Song"
    var disc_number: Int = 0
    var track_number: Int = 0
    var artist_name: String = "Preview Artist"
    var isrc: String = "Preview ISRC"
    var duration_in_ms: Int = 1
    var album_name: String = "Preview Album"
    var album_release_date: Date?
    var album_artwork_cover: URL?
    var album_artwork_width: Int?
    var album_artwork_height: Int?
    
    var fixedName: String {
        var fixedName = name.components(separatedBy: "-").first ?? name
        fixedName = fixedName.components(separatedBy: "(").first ?? name
        fixedName = fixedName.replacingOccurrences(of: "`", with: "'")
        fixedName = fixedName.replacingOccurrences(of: "fuck", with: "f**k", options: .caseInsensitive)
        fixedName = fixedName.trimmingCharacters(in: .whitespaces)
        
        // If original Name contained live, it should be added back to the fixed Name, but only if it has been removed from the fixedName in previous steps
        if (name.lowercased().contains("live") && !fixedName.lowercased().contains("live")) {
            fixedName = fixedName + " live"
        }
        
        return fixedName
    }
}

enum Service: String, Identifiable {
    case spotify, appleMusic
    var id: Self { self }
}

@Observable class SyncController {
    var selectedSource: Service = .spotify
    var selectedTarget: Service = .appleMusic
    
    var syncMatchingLimit: Double = 5.0
    var useAdvancedSync: Bool = false
    
    var addingPlaylist: Bool = false
}
