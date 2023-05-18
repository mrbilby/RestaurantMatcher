//
//  ContentView.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 24/04/2023.
//

/*
 
 Restaurant matcher

 */

import SwiftUI
import MapKit
import UIKit
import CoreLocation


struct ContentView: View {
    //@State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.33472222, longitude: -122.00888889), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @StateObject var managerDelegate = locationDelegate()
    @State var manager = CLLocationManager()
    @State var tracking : MapUserTrackingMode = .follow
    
    @State private var places: [Place] = []
    @State private var selectedPlace: Place?
    @State private var showingPlaceDetails = false
    @State private var examplePlace = CLLocationCoordinate2D(latitude: 37.33472222, longitude: -122.00888889)
    let locationManager = CLLocationManager()

    // Request authorization when the app is in use


    @StateObject var viewBinding = viewCheck()
    @State private var showingEditView = false
    @State private var showLikesView = false
    @State private var showMatchedView = false
    @State private var showNoMatchedView = false
    

    @StateObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @StateObject var currentUser = userPosition()
    @StateObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @State private var isDarkMode = false
    private var matchedDecision: [Place] {
        firstDecision.restaurantsLiked.filter { secondDecision.restaurantsLiked.contains($0) }
    }
    private var sheetBinding: Binding<Bool> {
        Binding(
            get: { currentUser.currentUser == 3 && showMatchedView && !matchedDecision.isEmpty },
            set: { showMatchedView = $0 }
        )
    }
    
    private var noMatchBinding: Binding<Bool> {
        Binding(
            get: { currentUser.currentUser == 3 && showMatchedView && matchedDecision.isEmpty },
            set: { showNoMatchedView = $0 }
        )
    }
    
    
    var body: some View {
        
        
        VStack {
            HStack {
                Button {
                    currentUser.currentUser = 1
                    viewBinding.showLikesView = false
                    viewBinding.showMatchedView = false
                    viewBinding.showingEditView = false
                    firstDecision.restaurantsLiked.removeAll()
                    secondDecision.restaurantsLiked.removeAll()
                    isDarkMode = false

                } label: {
                    Text("Reset")
                }
                .padding(.leading)
                Spacer()
                Button {
                    
                } label: {
                    Text("Options")
                }
                .padding(.trailing)
            }
            ZStack {
                
                //Map(coordinateRegion: $managerDelegate.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking)
                Map(coordinateRegion: $managerDelegate.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: places) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Button(action: {
                            self.selectedPlace = place
                            self.showingPlaceDetails = true
                        }) {
                            PulsatingMarker()
                        }
                    }
                }
                .onAppear {
                    manager.delegate = managerDelegate
                    searchForRestaurants()
                }

                
                if let selectedPlace = selectedPlace {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingEditView = true
                                //self.selectedPlace = nil
                                //self.showingPlaceDetails = false
                            }) {
                                Text(selectedPlace.title ?? "Unknown")
                                    .font(.largeTitle)
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Capsule())
                                    .shadow(radius: 10)
                                    .padding(.trailing)
                                    .padding(.bottom)
                            }
                            .sheet(isPresented: $showingEditView) {
                                EditView(firstDecision: firstDecision, secondDecision: secondDecision, currentUser: currentUser, selectedPlace: selectedPlace)
                            }

                        }
                    }
                }

            }
            HStack {
                Spacer()
                Button {
                    showLikesView.toggle()
                } label: {
                    VStack {
                        Text("Likes")
                        
                    }
                }
                .sheet(isPresented: $showLikesView) {
                    showLikes(firstDecision: firstDecision, currentUser: currentUser, secondDecision: secondDecision)
                }
                Spacer()
                Button {
                    searchForRestaurants()
                } label: {
                    VStack {
                        Text("Search")
                        
                    }
                }
                Spacer()
                
                Button {
                    
                    if currentUser.currentUser == 1 {
                        currentUser.currentUser = 2
                        isDarkMode = true

                    } else if currentUser.currentUser == 2{
                        currentUser.currentUser = 3
                        showMatchedView = true
                    }
                    print(currentUser.currentUser)
                } label : {
                    VStack {
                        Text("Done")
                        
                    }
                }
                .sheet(isPresented: sheetBinding) {
                    MatchingView(firstDecision: firstDecision, secondDecision: secondDecision, viewBinding: viewBinding, currentUser: currentUser, isDarkMode: $isDarkMode)
                }
                .sheet(isPresented: noMatchBinding) {
                    NoMatchView(firstDecision: firstDecision, secondDecision: secondDecision, viewBinding: viewBinding, currentUser: currentUser, isDarkMode: $isDarkMode)

                }
 
                Spacer()
            }
            

            
        }
        
        .background(isDarkMode ? Color.yellow : Color.white)
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }



    }
    
    
    func searchForRestaurants() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.region = managerDelegate.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            for item in response.mapItems {

                let place = Place(coordinate: item.placemark.coordinate, title: item.name, subtitle: item.phoneNumber, mapURL: item.url?.path)
                places.append(place)
            }
        }
    }


}

class locationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.33472222, longitude: -122.00888889), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
        ContentView(firstDecision: firstDecision)
    }
}
