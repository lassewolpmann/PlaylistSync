//
//  PlaylistsSeachFilter.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 16.6.2024.
//

import SwiftUI

struct PlaylistsSeachFilter: View {
    @Bindable var spotifyController: SpotifyController
    @Bindable var musicKitController: MusicKitController
    var syncController: SyncController
    
    var body: some View {
        LabeledContent {
            switch syncController.selectedSource {
            case .spotify:
                TextField("Search", text: $spotifyController.playlistOverviewFilter)
            case .appleMusic:
                TextField("Search", text: $musicKitController.playlistOverviewFilter)
            }
        } label: {
            Image(systemName: "magnifyingglass.circle")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
        )
    }
}

#Preview {
    PlaylistsSeachFilter(spotifyController: SpotifyController(), musicKitController: MusicKitController(), syncController: SyncController())
}
