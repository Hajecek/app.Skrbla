//
//  ImageRecognitionView.swift
//  Skrbla
//

import SwiftUI

struct ImageRecognitionView: View {
    var body: some View {
        ContentUnavailableView(
            "Skenování účtenky",
            systemImage: "camera.viewfinder",
            description: Text("Rozpoznávání z kamery připravíme, až bude napojené AI / backend.")
        )
        .navigationTitle("Skenovat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ImageRecognitionView()
    }
}
