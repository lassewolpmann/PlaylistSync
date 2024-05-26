//
//  PlaylistLabel.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 23.5.2024.
//

import SwiftUI

struct ItemLabel: View {
    let name: String
    let author: String
    let imageURL: String
    
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(author)
                    .font(.subheadline)
            }
        } icon: {
            LabelImage(url: imageURL)
        }
        .labelStyle(HorizontalAlignedLabel())
    }
}

#Preview {
    ItemLabel(name: "", author: "", imageURL: "")
}
