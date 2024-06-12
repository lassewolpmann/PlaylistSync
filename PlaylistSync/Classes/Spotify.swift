//
//  Spotify.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation
import CryptoKit
import AuthenticationServices

// TODO: Refreshing token

@Observable class SpotifyController {
    let clientID = "38171166fd9845f1846a9fa3bea2e925"
    let redirectURI = "playlistsync://com.lassewolpmann.PlaylistSync"
    
    var codeVerifier: String? = nil
    var codeChallenge: String? = nil
    var state: String? = nil
    
    var authSuccess: Bool = false
    var authData: AuthData? = nil
    
    var tokenRefreshDate: Date = Date()
    
    var playlistToSync: UserPlaylists.Playlist?
    
    init() {
        codeVerifier = self.generateRandomString(length: 64)
        codeChallenge = self.generateCodeChallenge()
        state = self.generateRandomString(length: 64)
    }
    
    private func generateRandomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func generateCodeChallenge() -> String {
        do {
            guard let verifierData = self.codeVerifier!.data(using: .utf8) else { throw SpotifyError.digestError("error") };
            let hashedVerifier = SHA256.hash(data: verifierData)
            let base64EncodedVerifier = Data(hashedVerifier).base64EncodedString()
                .replacingOccurrences(of: "=", with: "")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: .whitespaces)
            
            return base64EncodedVerifier
        } catch {
            return ""
        }
    }
    
    func generateRequestURL() throws -> URL? {
        guard let challenge = self.codeChallenge else { throw SpotifyError.challengeError("Invalid Code Challenge") }
        
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: self.clientID),
            URLQueryItem(name: "scope", value: "playlist-read-private user-read-private user-read-email"),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "state", value: self.state),
            URLQueryItem(name: "redirect_uri", value: self.redirectURI)
        ]
        
        return components?.url
    }
    
    func exchangeCodeForToken(urlWithCode: URL) async throws -> Void {
        let queryItems = URLComponents(string: urlWithCode.absoluteString)?.queryItems
        if let error = queryItems?.filter({ $0.name == "error" }).first?.value {
            print("Error while retrieving token: \(error)")
            return
        }
        
        guard let code = queryItems?.filter({ $0.name == "code" }).first?.value else { return }
        guard let state = queryItems?.filter({ $0.name == "state" }).first?.value else { return }
        
        do {
            try await self.createTokenRequest(code: code, state: state)
        } catch {
            print("Could not get code")
        }
    }
    
    private func createTokenRequest(code: String, state: String) async throws -> Void {
        if (state != self.state) {
            throw SpotifyError.stateError("State does not match")
        }
                
        guard let verifier = self.codeVerifier else { throw SpotifyError.verifierError("Invalid Code Verifier") }
        
        var components = URLComponents(string: "https://accounts.spotify.com/api/token")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: self.clientID),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: self.redirectURI),
            URLQueryItem(name: "code_verifier", value: verifier)
        ]
        
        let url = components?.url
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as! HTTPURLResponse).statusCode
        
        if (statusCode == 200) {
            self.authData = try JSONDecoder().decode(AuthData.self, from: data)
            self.authSuccess = true
            self.tokenRefreshDate = Date().addingTimeInterval(TimeInterval(self.authData?.expires_in ?? 0))
        } else {
            let errorData = try JSONDecoder().decode(AuthError.self, from: data)
            print(errorData)
        }
    }
    
    func getUserData() async throws -> UserData {
        guard let url = URL(string: "https://api.spotify.com/v1/me") else { throw SpotifyError.urlError("Could not get User Data URL") }
        guard let access_token = self.authData?.access_token else { throw SpotifyError.authError("No Access Token available.") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as! HTTPURLResponse).statusCode
        
        if (statusCode == 200) {
            let userData = try JSONDecoder().decode(UserData.self, from: data)
            return userData
        } else {
            let _ = try JSONDecoder().decode(GenericError.self, from: data)
            throw SpotifyError.dataError("Could not get User Data")
        }
    }
    
    func getUserPlaylists() async throws -> UserPlaylists {
        guard let access_token = self.authData?.access_token else { throw SpotifyError.authError("No Access Token available.") }
        
        var components = URLComponents(string: "https://api.spotify.com/v1/me/playlists")
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "offset", value: "0")
        ]
        
        guard let url = components?.url else { throw SpotifyError.urlError("Could not get User Playlists URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as! HTTPURLResponse).statusCode
        
        if (statusCode == 200) {
            let userPlaylists = try JSONDecoder().decode(UserPlaylists.self, from: data)
            return userPlaylists
        } else {
            let _ = try JSONDecoder().decode(GenericError.self, from: data)
            throw SpotifyError.dataError("Could not get User Playlists")
        }
    }
    
    func getPlaylist(playlistID: String) async throws -> SpotifyPlaylist {
        guard let access_token = self.authData?.access_token else { throw SpotifyError.authError("No Access Token available.") }
        
        guard let url = URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)") else { throw SpotifyError.urlError("Could not get User Playlists URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as! HTTPURLResponse).statusCode
                
        if (statusCode == 200) {
            let playlist = try JSONDecoder().decode(SpotifyPlaylist.self, from: data)
            
            return playlist
        } else {
            let _ = try JSONDecoder().decode(GenericError.self, from: data)
            throw SpotifyError.dataError("Could not get Playlist")
        }
    }
    
    func getPlaylistItems(url: String, total: Int) async throws -> [SpotifyPlaylist.Tracks.Track.TrackObject] {
        guard let access_token = self.authData?.access_token else { throw SpotifyError.authError("No Access Token available.") }
        
        var tracks: [SpotifyPlaylist.Tracks.Track.TrackObject] = []
        var requestURL: String? = url
        
        while (requestURL != nil) {
            if let url = requestURL {
                guard let url = URL(string: url) else { throw SpotifyError.urlError("Could not get Playlist Items URL") }
                var request = URLRequest(url: url)
                request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                if (statusCode == 200) {
                    let playlist = try JSONDecoder().decode(SpotifyPlaylist.Tracks.self, from: data)
                    requestURL = playlist.next
                    
                    let trackItems = playlist.items.map { $0.track }
                    tracks.append(contentsOf: trackItems)
                } else {
                    let _ = try JSONDecoder().decode(GenericError.self, from: data)
                    throw SpotifyError.dataError("Could not get Playlist")
                }
            }
        }
        
        return tracks
    }
    
    func createCommonData() async throws -> [CommonSongData] {
        if let playlist = self.playlistToSync {
            let items = try await self.getPlaylistItems(url: playlist.tracks.href, total: playlist.tracks.total)
            let commonSongData = items.map { item in
                let name = item.name
                let disc_number = item.disc_number
                let track_number = item.track_number
                let artist = item.artists.first?.name ?? "Unknown Artist"
                let isrc = item.external_ids.isrc ?? "Unknown ISRC"
                let duration_ms = item.duration_ms
                let album = item.album
                
                // Spotify has different precisions for the album release date. Therefore I need to check the precision first before setting the right format for the date formatter.
                let formatter = DateFormatter()
                
                if (album.release_date_precision == "year") {
                    formatter.dateFormat = "yyyy"
                } else if (album.release_date_precision == "month") {
                    formatter.dateFormat = "yyyy-MM"
                } else if (album.release_date_precision == "day") {
                    formatter.dateFormat = "yyyy-MM-dd"
                }
                
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                let date = formatter.date(from: album.release_date)
                
                let artwork_cover = item.album.images.first
                let artwork_cover_url = URL(string: artwork_cover?.url ?? "")
                
                return CommonSongData(name: name, disc_number: disc_number, track_number: track_number, artist_name: artist, isrc: isrc, duration_in_ms: duration_ms, album_name: album.name, album_release_date: date, album_artwork_cover: artwork_cover_url, album_artwork_width: artwork_cover?.width, album_artwork_height: artwork_cover?.height)
            }
            
            return commonSongData
        } else {
            throw SpotifyError.dataError("Could not create Common Data")
        }
    }
    
    func revokeToken() -> Void {
        self.authData = nil
        self.authSuccess = false
    }
}
