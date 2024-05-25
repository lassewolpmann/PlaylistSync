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
    var playlist: SpotifyPlaylist?
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label {
                Text("Sync \(playlist?.name ?? "unknown") to Apple Music")
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
            SpotifySyncSheet(playlist: playlist)
                .environment(musicKit)
        })
    }
}

#Preview {
    SpotifySyncButton()
        .environment(SpotifyController())
        .environment(MusicKitController())
}
