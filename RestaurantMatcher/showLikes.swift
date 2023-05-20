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
    @State private var showingEditView = false


    var body: some View {
        VStack {
            
            Text("Likes so far")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .shadow(radius: 10)
                .padding(.top)

            ScrollView{
                
                if currentUser.currentUser == 1 {
                    ForEach(Array(firstDecision.restaurantsLiked), id: \.self) { restauraunt in
                        Button {
                            showingEditView = true
                            
                        } label: {
                            Text(restauraunt.title ?? "Unknown")
                                .font(.title)
                        }
                        .sheet(isPresented: $showingEditView) {
                            EditView(firstDecision: firstDecision, secondDecision: secondDecision, currentUser: currentUser, selectedPlace: restauraunt)
                        }
                    }
                } else {
                    ForEach(Array(secondDecision.restaurantsLiked), id: \.self) { restauraunt in
                        Text(restauraunt.title ?? "Unknown")
                        
                    }
                    
                }
            }
        }
    }
}


