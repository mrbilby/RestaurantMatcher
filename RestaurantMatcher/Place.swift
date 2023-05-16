//
//  Place.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 02/05/2023.
//

import Foundation
import MapKit
import UIKit

class Place: NSObject, Identifiable, MKAnnotation {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let mapURL: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, mapURL: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.mapURL = mapURL
    }
}
