//
//  DataSelection.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 14.6.2024.
//

import SwiftUI

struct DataSelection: View {
    @Bindable var syncController: SyncController
    @State private var selection: Service? = .appleMusic
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text("Source")
                } icon: {
                    Image(systemName: "square.and.arrow.down")
                }
                
                Spacer()
                
                NavigationLink {
                    List(Service.allCases, selection: $syncController.selectedSource) {
                        Text($0.rawValue)
                    }
                } label: {
                    Text(syncController.selectedSource?.rawValue ?? "")
                }
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
    NavigationStack {
        DataSelection(syncController: SyncController())
    }
}
