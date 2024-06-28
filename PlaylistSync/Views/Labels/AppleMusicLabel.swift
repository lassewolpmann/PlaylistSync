//
//  AppleMusicLabel.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 28.6.2024.
//

import SwiftUI

struct AppleMusicLabel: View {
    var body: some View {
        Label {
            Text("Apple Music")
        } icon: {
            Image("AppleMusicIcon")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    AppleMusicLabel()
}
