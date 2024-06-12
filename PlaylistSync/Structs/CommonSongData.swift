//
//  CommonSongData.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 12.6.2024.
//

import Foundation

struct CommonSongData {
    var name: String
    var disc_number: Int
    var track_number: Int
    var artist_name: String
    var isrc: String
    var duration_in_ms: Int
    var album_name: String
    var album_release_date: Date?
    var album_artwork_cover: URL?
    var album_artwork_width: Int?
    var album_artwork_height: Int?
}
