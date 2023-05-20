//
//  MatchingView.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 14/05/2023.
//

import SwiftUI
import MapKit

struct MatchingView: View {
    @ObservedObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var viewBinding = viewCheck()
    @ObservedObject var currentUser = userPosition()
    @State private var selectedPlace: Place?
    @State private var showingPlaceDetails = false
    @State private var failedMatch = false

    @Environment(\.dismiss) var dismiss
    @Binding var isDarkMode: Bool
    private var matchedDecision: [Place] {
        firstDecision.restaurantsLiked.filter { first in
            secondDecision.restaurantsLiked.contains(where: { second in
                coordinatesEqual(first.coordinate, second.coordinate) && first.title == second.title
            })
        }
    }


    @Binding var region: MKCoordinateRegion
    
    //@State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.33472222, longitude: -122.00888889), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    var body: some View {
        VStack {
            
            ZStack {
                Text("Matched Locations")
                    .font(.title)
                    .fontWeight(.heavy)
                Map(coordinateRegion: $region, annotationItems: matchedDecision) { place in
                    
                    MapAnnotation(coordinate: place.coordinate) {
                        Button(action: {
                            self.selectedPlace = place
                            self.showingPlaceDetails = true
                        }) {
                            PulsatingMarker(color: Color.green)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                if let selectedPlace = selectedPlace {
                    VStack {
                        Spacer()
                        HStack {
                            Text(selectedPlace.title ?? "Unknown")
                                .foregroundColor(Color.blue)
                            Text(selectedPlace.subtitle ?? "Unknown")
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .clipShape(Capsule())
                        .shadow(radius: 10)
                        .padding(.trailing)
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                openGoogleReviews(selectedPlace)

                            }) {
                                Text("Reviews")

                            }
                            .font(.title)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                            .padding(.trailing)
                            .padding(.bottom)
                            



                        }
                    }
                }

            }
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
                dismiss()
            } label: {
                Text("Start Over")
            }
            Spacer()
        }
        .onAppear {
            updateRegion()
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
    func updateRegion() {
        guard !matchedDecision.isEmpty else {
            // Handle the case where matchedDecision is empty.
            print("No matched decision available.")
            print(firstDecision.restaurantsLiked)
            print(secondDecision.restaurantsLiked)

            failedMatch = true
            return
        }

        region = MKCoordinateRegion(
            center: matchedDecision[0].coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    }
    func coordinatesEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

}


/*
 let array1 = [1, 2, 3, 4, 5]
 let array2 = [3, 4, 5, 6, 7]

 let commonElements = array1.filter { array2.contains($0) }

 print(commonElements) // [3, 4, 5]
 */


