//
//  DataSelection.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI

struct DataSelection: View {
    @Bindable var syncController: SyncController
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Data Selection")
                .font(.headline)
            
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text("Source")
                } icon: {
                    Image(systemName: "square.and.arrow.down")
                }
                
                Spacer()
                
                Picker("Source", selection: $syncController.selectedSource) {
                    Text("Spotify").tag(Service.spotify)
                    Text("Apple Music").tag(Service.appleMusic)
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text("Target")
                } icon: {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Spacer()
                
                Picker("Target", selection: $syncController.selectedTarget) {
                    Text("Spotify").tag(Service.spotify)
                    Text("Apple Music").tag(Service.appleMusic)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
        )
    }
}

#Preview {
    DataSelection(syncController: SyncController())
}
