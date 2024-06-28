//
//  HorizontalAlignedLabel.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 26.5.2024.
//

import Foundation
import SwiftUI

struct HorizontalAlignedLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
            configuration.title
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
