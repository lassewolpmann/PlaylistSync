//
//  ContentView.swift
//  PlaylistSync
//
//  Created by Lasse Wolpmann on 21.5.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                Task {
                    let request = await authorize();
                    print(request);
                }
            } label: {
                Text("Authorize MusicKit")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
