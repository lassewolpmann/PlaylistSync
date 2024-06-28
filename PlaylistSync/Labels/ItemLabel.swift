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
    
    struct LabelImage: View {
        let url: String
        
        var body: some View {
            let imageURL = URL(string: url)
            
            AsyncImage(url: imageURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView().progressViewStyle(.circular)
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .shadow(radius: 10)
        }
    }
}

#Preview {
    let playlist = UserPlaylists().items.first
    
    return ItemLabel(name: playlist?.name ?? "", author: playlist?.owner.display_name ?? "", imageURL: playlist?.images.first?.url ?? "")
}
