//
//  SpotifyResponses.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation

struct AuthData: Decodable {
    var access_token: String
    var token_type: String
    var scope: String
    var expires_in: Int
    var refresh_token: String
}

struct AuthError: Decodable {
    var error: String
    var error_description: String
}

struct GenericError: Decodable {
    var status: Int
    var message: String
}

struct UserData: Decodable {
    struct ExplicitContent: Decodable {
        var filter_enabled: Bool
        var filter_locked: Bool
    }
    
    struct ExternalURLs: Decodable {
        var spotify: String
    }
    
    struct Followers: Decodable {
        var href: String?
        var total: Int
    }
    
    struct Image: Decodable {
        var url: String
        var height: Int
        var width: Int
    }
    
    var country: String
    var display_name: String
    var email: String
    var explicit_content: ExplicitContent
    var external_urls: ExternalURLs
    var followers: Followers
    var href: String
    var id: String
    var images: [Image]
    var product: String
    var type: String
    var uri: String
}
