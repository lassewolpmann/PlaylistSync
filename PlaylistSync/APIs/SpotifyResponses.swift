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
    var total: Int = 0
}

struct ExternalURLs: Decodable {
    var spotify: String = ""
}

struct ExternalImage: Decodable {
    var url: String = "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228"
    var height: Int?
    var width: Int?
}

struct Owner: Decodable {
    var external_urls: ExternalURLs = ExternalURLs()
    var followers: Followers?
    var href: String = ""
    var id: String = "preview_owner"
    var type: String = "Preview"
    var uri: String = ""
    var display_name: String? = "Preview Owner"
}

struct UserData: Decodable {
    // https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
    var display_name: String = "Preview User"
    var href: String = ""
    var id: String = "preview_user"
    var images: [ExternalImage] = [ExternalImage()]
    var product: String = ""
    var type: String = ""
    var uri: String = ""
}

struct UserPlaylists: Decodable {
    // https://developer.spotify.com/documentation/web-api/reference/get-list-users-playlists
    
    struct Playlist: Decodable, Hashable {
        static func == (lhs: UserPlaylists.Playlist, rhs: UserPlaylists.Playlist) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        struct Tracks: Decodable {
            var href: String = ""
            var total: Int = 0
        }
        
        var collaborative: Bool = false
        var description: String = "Preview User Playlist"
        var external_urls: ExternalURLs = ExternalURLs()
        var href: String = ""
        var id: String = "preview_user_playlist"
        var images: [ExternalImage] = [ExternalImage()]
        var name: String = "Preview User Playlist"
        var owner: Owner = Owner()
        var `public`: Bool = true
        var snapshot_id: String = ""
        var tracks: Tracks = Tracks()
        var type: String = ""
        var uri: String = ""
    }
    
    var href: String = ""
    var limit: Int = 0
    var next: String?
    var offset: Int = 0
    var previous: String?
    var total: Int = 1
    var items: [UserPlaylists.Playlist] = [UserPlaylists.Playlist()]
}

struct SpotifyPlaylist: Decodable {
    // https://developer.spotify.com/documentation/web-api/reference/get-playlist
    
    struct Tracks: Decodable {
        struct Track: Decodable {
            struct TrackObject: Decodable {
                // Values if track is a TrackObject
                struct Album: Decodable {
                    var album_type: String = ""
                    var total_tracks: Int = 1
                    var images: [ExternalImage] = [ExternalImage()]
                    var name: String = "Preview Album"
                    var release_date: String = ""
                }
                
                struct Artist: Decodable {
                    var name: String = "Preview Artist"
                }
                
                struct ExternalIDs: Decodable {
                    var isrc: String?
                    var ean: String?
                    var upc: String?
                }
                
                
                var album: SpotifyPlaylist.Tracks.Track.TrackObject.Album = SpotifyPlaylist.Tracks.Track.TrackObject.Album()
                var artists: [SpotifyPlaylist.Tracks.Track.TrackObject.Artist] = [SpotifyPlaylist.Tracks.Track.TrackObject.Artist()]
                var disc_number: Int = 0
                var duration_ms: Int = 0
                var explicit: Bool = true
                var external_ids: SpotifyPlaylist.Tracks.Track.TrackObject.ExternalIDs = SpotifyPlaylist.Tracks.Track.TrackObject.ExternalIDs()
                var id: String = "preview_track_object"
                var name: String = "Preview Track Object"
                var track_number: Int = 0
                
                // Values if track is an EpisodeObject
                // Since we don't care about episodes, I'll just let the decoding fail on this one
            }
            
            var added_at: String?
            var added_by: Owner?
            var is_local: Bool = false
            var track: SpotifyPlaylist.Tracks.Track.TrackObject = SpotifyPlaylist.Tracks.Track.TrackObject()
        }
        
        var href: String = ""
        var limit: Int = 0
        var next: String?
        var offset: Int = 0
        var previous: String?
        var total: Int = 1
        var items: [SpotifyPlaylist.Tracks.Track] = [SpotifyPlaylist.Tracks.Track()]
    }
    
    var collaborative: Bool = false
    var description: String = "Preview Spotify Playlist"
    var external_urls: ExternalURLs = ExternalURLs()
    var followers: Followers = Followers()
    var href: String = ""
    var id: String = "preview_spotify_playlist"
    var images: [ExternalImage] = [ExternalImage()]
    var name: String = "Preview Spotify Playlist"
    var owner: Owner = Owner()
    var `public`: Bool = true
    var snapshot_id: String = ""
    var tracks: SpotifyPlaylist.Tracks = SpotifyPlaylist.Tracks()
    var type: String = ""
    var uri: String = ""
}

