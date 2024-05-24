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
    
    struct ItemLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center) {
                configuration.icon
                configuration.title
            }
        }
    }
    
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
        .labelStyle(ItemLabelStyle())
    }
}

#Preview {
    ItemLabel(name: "", author: "", imageURL: "")
}
