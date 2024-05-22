//
//  Spotify.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import Foundation
import CryptoKit
import AuthenticationServices

enum SpotifyError: Error {
    case digestError(String)
    case challengeError(String)
    case verifierError(String)
    case stateError(String)
}

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

class SpotifyController {
    let clientID = "38171166fd9845f1846a9fa3bea2e925"
    let redirectURI = "playlistsync://com.lassewolpmann.PlaylistSync"
    
    var codeVerifier: String? = nil
    var codeChallenge: String? = nil
    var state: String? = nil
    
    var authData: AuthData? = nil
    
    init() {
        let verifier = self.generateRandomString(length: 64)
        let challenge = self.generateCodeChallenge(verifier: verifier)
        
        codeVerifier = verifier
        codeChallenge = challenge
        state = self.generateRandomString(length: 64)
    }
    
    private func generateRandomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func generateCodeChallenge(verifier: String?) -> String {
        do {
            guard let verifierData = verifier!.data(using: .utf8) else { throw SpotifyError.digestError("error") };
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
            URLQueryItem(name: "scope", value: "playlist-read-private"),
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
        } else {
            let errorData = try JSONDecoder().decode(AuthError.self, from: data)
        }
    }
}
