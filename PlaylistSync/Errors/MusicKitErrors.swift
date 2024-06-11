//
//  MusicKitErrors.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import Foundation

enum MusicKitError: Error {
    case matchingError(String)
    case resourceError(String)
    case artworkError(String)
}
