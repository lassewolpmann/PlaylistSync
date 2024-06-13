//
//  SyncSheet.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 13.6.2024.
//

import SwiftUI

struct SyncSheet: View {
    var spotifyController: SpotifyController
    var musicKitController: MusicKitController
    
    var selectedSource: Service
    var selectedTarget: Service
    
    @State var commonSongData: [CommonSongData] = []
    @State var playlistName: String = ""
    
    var body: some View {
        NavigationStack {
            if (spotifyController.loadingCommonData || musicKitController.loadingCommonData) {
                ProgressView {
                    Text("Loading data...")
                }
            } else {
                List(commonSongData, id: \.self) { song in
                    ItemLabel(name: song.name, author: song.artist_name, imageURL: song.album_artwork_cover?.absoluteString ?? "")
                }
                .navigationTitle(playlistName)
                .onAppear {
                    switch selectedSource {
                    case .spotify:
                        playlistName = spotifyController.playlistToSync?.name ?? "Playlist"
                        if let items = spotifyController.commonSongData {
                            commonSongData = items
                        }
                    case .appleMusic:
                        playlistName = musicKitController.playlistToSync?.name ?? "Playlist"
                        if let items = musicKitController.commonSongData {
                            commonSongData = items
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let spotifyController = SpotifyController()
    let musicKitController = MusicKitController()
    let previewSongData = CommonSongData(name: "Preview Song", disc_number: 0, track_number: 0, artist_name: "Preview Artist", isrc: "", duration_in_ms: 1, album_name: "Preview Album", album_artwork_cover: URL(string: "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228"))
    
    spotifyController.commonSongData = [previewSongData, previewSongData, previewSongData]
    
    return VStack {
        Text("Preview")
    }.sheet(isPresented: .constant(true)) {
        SyncSheet(spotifyController: spotifyController, musicKitController: musicKitController, selectedSource: Service.spotify, selectedTarget: Service.appleMusic)
    }
}
