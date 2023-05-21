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
    
    @State private var flipped = false
    @State private var angle: Double = 0
    @State private var animate3d = false
    
    @State private var places: [Place] = []
    @State private var selectedPlace: Place?
    @State private var showingPlaceDetails = false
    @State private var examplePlace = CLLocationCoordinate2D(latitude: 37.33472222, longitude: -122.00888889)
    let locationManager = CLLocationManager()
    
    @State private var showUserText = false

    @StateObject var viewBinding = viewCheck()
    @State private var showingEditView = false
    @State private var showLikesView = false
    @State private var showMatchedView = false
    @State private var showNoMatchedView = false
    @State private var showInstructionsView = false
    
    @State private var colourChoice = Color.orange

    @StateObject var firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @StateObject var currentUser = userPosition()
    @StateObject var secondDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
    @State private var isDarkMode = false
    private var matchedMainDecision: [Place] {
        firstDecision.restaurantsLiked.filter { first in
            secondDecision.restaurantsLiked.contains(where: { second in
                coordinatesEqual(first.coordinate, second.coordinate) && first.title == second.title
            })
        }
    }
    
    private var sheetBinding: Binding<Bool> {
        Binding(
            
            get: { currentUser.currentUser == 3 && showMatchedView && !matchedMainDecision.isEmpty },
            set: { showMatchedView = $0 }
             
        )
    }
    
    
    private var noMatchBinding: Binding<Bool> {
        Binding(
            get: { currentUser.currentUser == 3 && showMatchedView && matchedMainDecision.isEmpty },
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
                    firstDecision.restaurantsDisLiked.removeAll()
                    secondDecision.restaurantsDisLiked.removeAll()
                    isDarkMode = false
                    withAnimation(.linear(duration: 1)) {
                        self.animate3d.toggle()
                    }
                    self.flipped.toggle()
                    searchForRestaurants()

                } label: {
                    Text("Reset")
                }
                .padding(.leading)
                Spacer()
                Text("Player \(currentUser.currentUser)")
                    .font(.title3).foregroundColor(Color.black).shadow(radius: 10)
                Spacer()
                Button {
                    showInstructionsView = true
                } label: {
                    Text("Instructions")
                }
                .padding(.trailing)
                .sheet(isPresented: $showInstructionsView) {
                    InstructionsView()
                }
            }
            ZStack {
                
                //Map(coordinateRegion: $managerDelegate.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking)
                Map(coordinateRegion: $managerDelegate.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: places) { place in
                    MapAnnotation(coordinate: place.coordinate) {

                        Button(action: {
                            print("Press")
                            self.selectedPlace = place
                            self.showingPlaceDetails = true
    
                            
                        }) {
                            PulsatingMarker(
                                firstDecision: firstDecision,
                                secondDecision: secondDecision,
                                currentUser: currentUser,
                                color:
                                    (firstDecision.restaurantsLiked.contains(place) && currentUser.currentUser == 1) ||
                                    (secondDecision.restaurantsLiked.contains(place) && currentUser.currentUser == 2)
                                    ? Color.green
                                    : (firstDecision.restaurantsDisLiked.contains(place) && currentUser.currentUser == 1) ||
                                      (secondDecision.restaurantsDisLiked.contains(place) && currentUser.currentUser == 2)
                                      ? Color.red
                                      : Color.orange
                            )
                        }
                    }
                }
                .onAppear {
                    manager.delegate = managerDelegate
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
                    
                    withAnimation(.linear(duration: 1)) {
                        self.animate3d.toggle()
                    }
                    self.flipped.toggle()
                    searchForRestaurants()

                } label : {
                    VStack {
                        Text("Done")
                        
                    }
                }
                .sheet(isPresented: sheetBinding) {
                    MatchingView(firstDecision: firstDecision, secondDecision: secondDecision, viewBinding: viewBinding, currentUser: currentUser, isDarkMode: $isDarkMode, region: $managerDelegate.region)
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
        .rotation3DEffect(.degrees(angle), axis: (x: animate3d ? 1 : 0, y: 0, z: 0))
        .onChange(of: animate3d, perform: { value in
            withAnimation(.linear(duration: 0.5)) {
                angle += 360
            }
        })



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
    func coordinatesEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }


}

class locationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.50, longitude: -98.35), span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
    private var didSetInitialRegion = false
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if !didSetInitialRegion {
                region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                didSetInitialRegion = true
            }
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let firstDecision = userDecision(restaurantsLiked: [], restaurantsDisLiked: [])
        ContentView(firstDecision: firstDecision)
    }
}
