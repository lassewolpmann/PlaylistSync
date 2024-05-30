//
//  SpotifySyncButton.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 25.5.2024.
//

import SwiftUI

struct SpotifySyncButton: View {
    @Binding var showSheet: Bool
    let playlistName: String
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label {
                Text("Sync \(playlistName) to Apple Music")
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.bottom, 10)
    }
}

#Preview {
    SpotifySyncButton(showSheet: .constant(false), playlistName: SpotifyPlaylist().name)
}
