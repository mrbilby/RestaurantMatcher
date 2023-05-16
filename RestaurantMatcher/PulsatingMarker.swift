//
//  PulsatingMarker.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 15/05/2023.
//

import SwiftUI

struct PulsatingMarker: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    let animationDuration: Double = 1.5
    let minOpacity: Double = 0.5 // Adjust the minimum opacity here
    let markerSize: CGFloat = 20.0
    let markerColor = Color.red
    let markerBorderColor = Color.white
    let markerBorderWidth: CGFloat = 2.0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.orange)
                .frame(width: 30, height: 30)
                .scaleEffect(scale)
                .opacity(opacity)
                .overlay(
                    Circle()
                        .stroke(markerBorderColor, lineWidth: markerBorderWidth)
                )
                .animation(
                    Animation.easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true)
                )
        }
        .onAppear {
            withAnimation {
                scale = 1.2
                opacity = minOpacity
            }
        }
    }
}

struct PulsatingMarker_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingMarker()
    }
}
