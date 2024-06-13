//
//  SyncSettingsView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 12.6.2024.
//

import SwiftUI

struct SyncSettings: View {
    @State var showSliderInfo = false
    @State var showToggleInfo = false
    
    @Binding var matchingLimit: Double
    @Binding var useAdvancedMatching: Bool
    
    var body: some View {
        Section {
            HStack(spacing: 15) {
                VStack(alignment: .leading) {
                    Slider(
                        value: $matchingLimit,
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
                        Text("Current Matching Limit: \(Int(matchingLimit))")
                    } icon: {
                        Image(systemName: "magnifyingglass.circle")
                            .foregroundStyle(.green)
                    }
                }
                
                Button {
                    showSliderInfo.toggle()
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
            
            HStack(spacing: 15) {
                Toggle(isOn: $useAdvancedMatching) {
                    Label {
                        Text("Advanced Sync")
                    } icon: {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(.green)
                    }
                }
                
                Button {
                    showToggleInfo.toggle()
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        } header: {
            Text("Sync Settings")
        }
        .sheet(isPresented: $showSliderInfo, content: {
            VStack(alignment: .leading, spacing: 15) {
                Label {
                    Text("Matching Limit")
                        .font(.title)
                } icon: {
                    Image(systemName: "magnifyingglass.circle")
                        .foregroundStyle(.green)
                }
                
                Text("This settings changes the amount of songs the App searches for when trying to match the Playlist.")
                Text("Increasing this value does not have a big effect on the time it requires to do the search.")
                Text("It does have a big impact though, if used together with Advanced Sync.").bold()
            }
            .padding()
        })
        .sheet(isPresented: $showToggleInfo, content: {
            VStack(alignment: .leading, spacing: 15) {
                Label {
                    Text("Advanced Sync")
                        .font(.title)
                } icon: {
                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(.green)
                }
                
                Text("Enabling this option will enable some more advanced syncing methods like album image recognition.")
                Text("This might return better results but also increases the amount of time the matching process will take.")
                Text("Advanced Sync works best on newer and more capable hardware.").bold()
            }
            .padding()
        })
    }
}

#Preview {
    List {
        SyncSettings(matchingLimit: .constant(5.0), useAdvancedMatching: .constant(false))
    }
}
