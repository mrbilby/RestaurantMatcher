//
//  showLikes.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 14/05/2023.
//

import SwiftUI

struct showLikes: View {
    @ObservedObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var currentUser = userPosition()
    @ObservedObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])


    var body: some View {
        VStack {
            if currentUser.currentUser == 1 {
                ForEach(Array(firstDecision.restaurantsLiked), id: \.self) { restauraunt in
                    Text(restauraunt.title ?? "Unknown")
                }
            } else {
                ForEach(Array(secondDecision.restaurantsLiked), id: \.self) { restauraunt in
                    Text(restauraunt.title ?? "Unknown")
                    
                }

            }
        }
    }
}


