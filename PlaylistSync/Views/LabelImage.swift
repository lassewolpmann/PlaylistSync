//
//  LabelImage.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 23.5.2024.
//

import SwiftUI

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

#Preview {
    LabelImage(url: "")
}
