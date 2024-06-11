//
//  SpotifyErrors.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 11.6.2024.
//

import Foundation

enum SpotifyError: Error {
    case digestError(String)
    case challengeError(String)
    case verifierError(String)
    case stateError(String)
    case authError(String)
    case dataError(String)
    case urlError(String)
}
