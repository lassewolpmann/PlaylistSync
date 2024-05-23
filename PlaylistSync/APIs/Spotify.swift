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

enum SpotifyError: Error {
    case digestError(String)
    case challengeError(String)
    case verifierError(String)
    case stateError(String)
    case authError(String)
    case dataError(String)
    case urlError(String)
}

@Observable
final class SpotifyController {
    let clientID = "38171166fd9845f1846a9fa3bea2e925"
    let redirectURI = "playlistsync://com.lassewolpmann.PlaylistSync"
    
    var codeVerifier: String? = nil
    var codeChallenge: String? = nil
    var state: String? = nil
    
    var authSuccess: Bool = false
    var authData: AuthData? = nil
    
    var tokenRefreshDate: Date = Date()
    
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
    
    func revokeToken() -> Void {
        self.authData = nil
        self.authSuccess = false
    }
}
