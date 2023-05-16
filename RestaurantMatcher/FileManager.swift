//
//  FileManager.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 24/04/2023.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
