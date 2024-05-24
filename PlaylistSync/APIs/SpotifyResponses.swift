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

struct Followers: Decodable {
    var href: String?
    var total: Int
}

struct ExternalURLs: Decodable {
    var spotify: String
}

struct ExternalImage: Decodable {
    var url: String
    var height: Int?
    var width: Int?
}

struct Owner: Decodable {
    var external_urls: ExternalURLs
    var followers: Followers?
    var href: String
    var id: String
    var type: String
    var uri: String
    var display_name: String?
}

struct UserData: Decodable {
    // https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
    
    struct ExplicitContent: Decodable {
        var filter_enabled: Bool
        var filter_locked: Bool
    }
    
    var country: String
    var display_name: String
    var email: String
    var explicit_content: ExplicitContent
    var external_urls: ExternalURLs
    var followers: Followers
    var href: String
    var id: String
    var images: [ExternalImage]
    var product: String
    var type: String
    var uri: String
}

struct UserPlaylists: Decodable {
    // https://developer.spotify.com/documentation/web-api/reference/get-list-users-playlists
    
    struct Playlist: Decodable {
        struct Tracks: Decodable {
            var href: String
            var total: Int
        }
        
        var collaborative: Bool
        var description: String
        var external_urls: ExternalURLs
        var href: String
        var id: String
        var images: [ExternalImage]
        var name: String
        var owner: Owner
        var `public`: Bool
        var snapshot_id: String
        var tracks: Tracks
        var type: String
        var uri: String
    }
    
    var href: String
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
    var items: [Playlist]
}

struct SpotifyPlaylist: Decodable {
    // https://developer.spotify.com/documentation/web-api/reference/get-playlist
    
    struct Tracks: Decodable {
        struct Track: Decodable {
            struct TrackObject: Decodable {
                // Values if track is a TrackObject
                struct Album: Decodable {
                    var album_type: String
                    var total_tracks: Int
                    var images: [ExternalImage]
                    var name: String
                    var release_date: String
                }
                
                struct Artist: Decodable {
                    var name: String
                }
                
                struct ExternalIDs: Decodable {
                    var isrc: String?
                    var ean: String?
                    var upc: String?
                }
                
                
                var album: Album
                var artists: [Artist]
                var disc_number: Int
                var duration_ms: Int
                var explicit: Bool
                var external_ids: ExternalIDs
                var id: String
                var name: String
                var track_number: Int
                
                // Values if track is an EpisodeObject
                // Since we don't care about episodes, I'll just let the decoding fail on this one
            }
            
            var added_at: String?
            var added_by: Owner?
            var is_local: Bool
            var track: TrackObject
        }
        
        var href: String
        var limit: Int
        var next: String?
        var offset: Int
        var previous: String?
        var total: Int
        var items: [Track]
    }
    
    var collaborative: Bool
    var description: String
    var external_urls: ExternalURLs
    var followers: Followers
    var href: String
    var id: String
    var images: [ExternalImage]
    var name: String
    var owner: Owner
    var `public`: Bool
    var snapshot_id: String
    var tracks: Tracks
    var type: String
    var uri: String
}
