//
//  SpotifyView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 22.5.2024.
//

import SwiftUI
import AuthenticationServices

struct SpotifyView: View {
    @State private var spotify = SpotifyController()
    @State private var userName: String = ""
    
    var body: some View {
        VStack {
            if (spotify.authSuccess) {
                Text("Hello \(userName)")
                Button {
                    Task {
                        do {
                            let userData = try await spotify.getUserData()
                            userName = userData.display_name
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Get User data")
                }
            } else {
                SpotifyAuthButton()
                    .environment(spotify)
            }
        }
    }
}

#Preview {
    SpotifyView()
}
