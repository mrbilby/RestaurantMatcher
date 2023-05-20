//
//  Location.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 24/04/2023.
//

import Foundation
import MapKit

class userDecision: ObservableObject {
    @Published var choice = false
    @Published var user = 1
    @Published var restaurantsLiked: Set<Place>
    @Published var restaurantsDisLiked: Set<Place>
    
    init(choice: Bool = false, user: Int = 1, restaurantsLiked: Set<Place>, restaurantsDisLiked: Set<Place>) {
        self.choice = choice
        self.user = user
        self.restaurantsLiked = restaurantsLiked
        self.restaurantsDisLiked = restaurantsDisLiked
    }

}

