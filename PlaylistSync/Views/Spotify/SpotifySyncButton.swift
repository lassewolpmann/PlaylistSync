//
//  SpotifySyncButton.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import SwiftUI

struct SpotifySyncButton: View {
    @Environment(SpotifyController.self) private var spotify
    @Environment(MusicKitController.self) private var musicKit
    
    @State var showSheet: Bool = false
    
    let playlist: SpotifyPlaylist
    let playlistItems: [SpotifyPlaylist.Tracks.Track.TrackObject]
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label {
                Text("Sync \(playlist.name) to Apple Music")
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
        .sheet(isPresented: $showSheet, content: {
            SpotifySyncSheet(playlist: playlist, playlistItems: playlistItems)
                .environment(musicKit)
                .presentationBackground(.ultraThinMaterial)
        })
    }
}

#Preview {
    SpotifySyncButton(playlist: SpotifyPlaylist(collaborative: false, description: "", external_urls: ExternalURLs(spotify: ""), followers: Followers(total: 0), href: "", id: "", images: [], name: "", owner: Owner(external_urls: ExternalURLs(spotify: ""), href: "", id: "", type: "", uri: ""), public: false, snapshot_id: "", tracks: SpotifyPlaylist.Tracks(href: "", limit: 0, offset: 0, total: 0, items: []), type: "", uri: ""), playlistItems: [])
        .environment(SpotifyController())
        .environment(MusicKitController())
}
