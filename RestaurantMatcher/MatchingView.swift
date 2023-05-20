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
                                .font(.largeTitle)
                            if let number = selectedPlace.subtitle?.filter("+0123456789.".contains), let url = URL(string: "tel:\(number)") {
                                Link(number, destination: url)
                                    .foregroundColor(.black) // Set the link text color to blue
                                    .underline() // Add an underline to the link text
                                    .font(.headline) // Apply a different font to the link text
                            } else {
                                Text("Unknown")
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.5))
                        .clipShape(Capsule())
                        .shadow(radius: 10)
                        .padding(.trailing)
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                openGoogleReviews(selectedPlace)

                            }) {
                                Text("Google")

                            }
                            .font(.title)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                            .padding(.trailing)
                            .padding(.bottom)
                            
                            Button(action: {
                                openYelpReviews(selectedPlace)

                            }) {
                                Text("Yelp")

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

        // Initialize the geocoder
        let geocoder = CLGeocoder()

        // Reverse geocode the coordinate
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            if let error = error {
                print("Failed to get location name: \(error)")
                return
            }

            // Get the first placemark from the results
            if let placemark = placemarks?.first {
                // Get the city
                let city = placemark.locality ?? ""

                // Create the search term combining place name and city
                let searchTerm = "\(name), \(city)"

                // Create the URL for the Google Maps website
                let urlStr = "https://www.google.com/maps/search/?api=1&query=\(searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                if let url = URL(string: urlStr) {
                    // Open the URL in the default browser
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func openYelpReviews(_ selectedPlace: Place) {
        // Get the name of the selected place
        let name = selectedPlace.title ?? "Unknown Place"

        // Get the coordinate of the selected place
        let coordinate = selectedPlace.coordinate

        // Initialize the geocoder
        let geocoder = CLGeocoder()

        // Reverse geocode the coordinate
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            if let error = error {
                print("Failed to get location name: \(error)")
                return
            }

            // Get the first placemark from the results
            if let placemark = placemarks?.first {
                // Get the city and country
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""

                // Create the location string
                let location = "\(city), \(country)"

                // Create the URL for the Yelp website
                let urlStr = "https://www.yelp.com/search?find_desc=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&find_loc=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                if let url = URL(string: urlStr) {
                    // Open the URL in the default browser
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
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
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
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


