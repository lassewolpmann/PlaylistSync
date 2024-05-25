//
//  SpotifySyncButton.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import SwiftUI

struct SpotifySyncButton: View {
    @Environment(MusicKitController.self) private var musicKit
    
    @State var playlists: Set<UserPlaylists.Playlist>
    
    var body: some View {
        Button {
            musicKit.syncSpotifyToMusicKit(playlists: playlists)
        } label: {
            Label {
                Text("Sync selected Playlists to Apple Music")
                    .fontWeight(.bold)
            } icon: {
                Image("AppleMusicIcon")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 25)
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
        .background(.ultraThinMaterial, in:
                        RoundedRectangle(cornerRadius: 10)
        )
        .padding(.bottom, 10)
    }
}

#Preview {
    SpotifySyncButton(playlists: [])
        .environment(MusicKitController())
}
