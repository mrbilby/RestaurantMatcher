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
    
    @ObservedObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var currentUser = userPosition()
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
                .scaleEffect(scale)
                .opacity(opacity)
                .overlay(
                    Circle()
                        .stroke(markerBorderColor, lineWidth: markerBorderWidth)
                )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                scale = 1.2
                opacity = minOpacity
            }
        }
    }
}

struct PulsatingMarker_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingMarker(color: Color.orange)
    }
}
