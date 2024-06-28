//
//  SyncSettingsView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 12.6.2024.
//

import SwiftUI

struct SyncSettings: View {
    @Bindable var syncController: SyncController
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 15) {
                Label {
                    Text("Settings")
                        .font(.title)
                } icon: {
                    Image(systemName: "gear")
                }
                
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 15) {
                        Slider(
                            value: $syncController.syncMatchingLimit,
                            in: 5...25,
                            step: 1
                        ) {
                            Text("Songs to search when syncing")
                        } minimumValueLabel: {
                            Text("5")
                        } maximumValueLabel: {
                            Text("25")
                        }
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        Label {
                            Text("Current Matching Limit: \(Int(syncController.syncMatchingLimit))")
                        } icon: {
                            Image(systemName: "magnifyingglass.circle")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.regularMaterial)
                )
                
                HStack(spacing: 15) {
                    Toggle(isOn: $syncController.useAdvancedSync) {
                        Label {
                            Text("Advanced Sync")
                        } icon: {
                            Image(systemName: "wand.and.stars")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.regularMaterial)
                )
                
                VStack(alignment: .leading) {
                    Text("Search Speed Impact")
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 10).fill(.green)
                        RoundedRectangle(cornerRadius: 10).fill(
                            syncController.syncMatchingLimit >= 10 || syncController.useAdvancedSync
                            ? .yellow : .yellow.opacity(0.25)
                        )
                        RoundedRectangle(cornerRadius: 10).fill(
                            syncController.syncMatchingLimit >= 15 && syncController.useAdvancedSync
                            ? .red : .red.opacity(0.25)
                        )
                    }
                    .animation(.easeInOut(duration: 0.2), value: syncController.syncMatchingLimit)
                    .animation(.easeInOut(duration: 0.2), value: syncController.useAdvancedSync)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.regularMaterial)
                )
                
                Divider()
                
                Label {
                    Text("Help")
                        .font(.title)
                } icon: {
                    Image(systemName: "questionmark.circle")
                }
                
                
                VStack(alignment: .leading, spacing: 15) {
                    Label {
                        Text("Matching Limit")
                            .font(.title2)
                    } icon: {
                        Image(systemName: "magnifyingglass.circle")
                            .foregroundStyle(.green)
                    }
                    
                    Text("This settings changes the amount of songs the App searches for when trying to match the Playlist.")
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Label {
                        Text("Advanced Sync")
                            .font(.title2)
                    } icon: {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(.green)
                    }
                    
                    Text("Enabling this option will enable some more advanced syncing methods like album image recognition.")
                    Text("This might return better results but also increases the amount of time the matching process will take.")
                }
            }
            .padding()
        }
    }
}

#Preview {
    SyncSettings(syncController: SyncController())
}
