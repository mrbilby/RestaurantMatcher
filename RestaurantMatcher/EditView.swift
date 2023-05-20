//
//  EditView.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 01/05/2023.
//

import SwiftUI
import MapKit
import CoreLocation


struct EditView: View {
    @ObservedObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @ObservedObject var currentUser = userPosition()
    @Environment(\.dismiss) var dismiss
    let selectedPlace: Place?

    
    var body: some View {
        VStack {
            Spacer()
            Text(selectedPlace?.title ?? "Unknown")
                .font(.largeTitle)
            if let number = selectedPlace?.subtitle?.filter("+0123456789.".contains), let url = URL(string: "tel:\(number)") {
                Link(number, destination: url)
            } else {
                Text("Unknown")
            }
            Spacer()
            Button {
                openGoogleReviews(selectedPlace!)
            } label: {
                Text("Check Google Reviews")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(40)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.blue, lineWidth: 5)
                    )
            }
            Spacer()
            Button {
                openYelpReviews(selectedPlace!)
            } label: {
                Text("Check Yelp Reviews")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(40)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.blue, lineWidth: 5)
                    )
            }
            Spacer()
            HStack {
                Button {
                    if currentUser.currentUser == 1 {
                        if let place = selectedPlace {
                            firstDecision.restaurantsLiked.insert(place)
                            print(place.coordinate)
                        }
                        print("First Liked")
                    } else {
                        if let place = selectedPlace {
                            secondDecision.restaurantsLiked.insert(place)
                            print(place.coordinate)

                        }
                        print("Second Liked")
                    }
                    dismiss()
                } label: {
                    Text("👍").font(.system(size: 150))
                    
                }
                Button {
                    if currentUser.currentUser == 1 {
                        if let place = selectedPlace {
                            firstDecision.restaurantsLiked.remove(place)
                            firstDecision.restaurantsDisLiked.insert(place)

                        }
                        print("First Disliked")
                    } else {
                        if let place = selectedPlace {
                            secondDecision.restaurantsLiked.remove(place)
                            secondDecision.restaurantsDisLiked.insert(place)

                        }
                        print("Second Liked")
                    }
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
}





struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        let userDecisionExample = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
        let userPositionExample = userPosition()

        return EditView(
            firstDecision: userDecisionExample,
            secondDecision: userDecisionExample,
            currentUser: userPositionExample,
            selectedPlace: Place(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), title: "Example Place", subtitle: "123 Example Street", mapURL: "www.blah.com")
        )
    }
}

