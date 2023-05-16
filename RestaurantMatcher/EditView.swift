//
//  EditView.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 01/05/2023.
//

import SwiftUI
import MapKit



struct EditView: View {
    @ObservedObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var viewBinding = viewCheck()
    @ObservedObject var currentUser = userPosition()
    @Environment(\.dismiss) var dismiss
    let selectedPlace: Place?

    
    var body: some View {
        VStack {
            Spacer()
            Text(selectedPlace?.title ?? "Unknown")
            Text(selectedPlace?.subtitle ?? "Missing place information.")
            Button {
                openGoogleReviews(selectedPlace!)
            } label: {
                Text("Check Reviews")
            }
            Spacer()
            HStack {
                Button {
                    if currentUser.currentUser == 1 {
                        if let place = selectedPlace {
                            firstDecision.restaurantsLiked.insert(place)
                        }
                        print("First Liked")
                    } else {
                        if let place = selectedPlace {
                            secondDecision.restaurantsLiked.insert(place)
                        }
                        print("Second Liked")
                    }
                    viewBinding.showingEditView = false
                    dismiss()
                } label: {
                    Text("👍").font(.system(size: 150))
                    
                }
                Button {
                    if currentUser.currentUser == 1 {
                        firstDecision.restaurantsDisLiked.append(selectedPlace?.title ?? "Unknown")
                        if let place = selectedPlace {
                            firstDecision.restaurantsLiked.remove(place)

                        }
                        print("First Disliked")
                    } else {
                        if let place = selectedPlace {
                            secondDecision.restaurantsLiked.remove(place)
                        }
                        print("Second Liked")
                    }
                    viewBinding.showingEditView = false
                    dismiss()

                } label: {
                    Text("👎").font(.system(size: 150))
                }
            }

        }
    }
    func openGoogleReviews(_ selectedPlace: Place) {
        // Get the name and coordinate of the selected place
        let name = selectedPlace.title ?? "Unknown Place"
        let coordinate = selectedPlace.coordinate

        // Create the URL for the Google reviews website
        let urlStr = "https://www.google.com/maps/search/?api=1&query=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&query_place_id=\(coordinate.latitude),\(coordinate.longitude)"
        guard let url = URL(string: urlStr) else { return }

        // Open the URL in the default browser
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

