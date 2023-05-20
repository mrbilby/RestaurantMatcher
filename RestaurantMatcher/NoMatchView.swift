//
//  NoMatchView.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 17/05/2023.
//

import SwiftUI

struct NoMatchView: View {
    @ObservedObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var viewBinding = viewCheck()
    @ObservedObject var currentUser = userPosition()
    @Binding var isDarkMode: Bool

    var body: some View {
        Text("NO MATCH FOR YOU")
        Spacer()
        Button {
            currentUser.currentUser = 1
            viewBinding.showLikesView = false
            viewBinding.showMatchedView = false
            viewBinding.showingEditView = false
            firstDecision.restaurantsLiked.removeAll()
            secondDecision.restaurantsLiked.removeAll()
            firstDecision.restaurantsDisLiked.removeAll()
            secondDecision.restaurantsDisLiked.removeAll()
            isDarkMode = false
        } label: {
            Text("Reset")
        }
        
    }
    
}


