//
//  MoonshotHelpers.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 24/11/2024.
//

import Foundation
import SwiftUI

struct MoonshotHelper {
    enum Error: Swift.Error {
        case custom(String)
    }
    
    static func loadFromFile<T: Decodable>(_ file: String) throws -> T {
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: file, withExtension: nil) else {
            throw Error.custom("Failed to locate \(file) in bundle.")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        let loaded = try decoder.decode(T.self, from: data)
        return loaded
    }
}

struct MoonshotTheme {
    static var darkBackground: Color {
        Color(red: 0.1, green: 0.1, blue: 0.2)
    }
    
    static var lightBackground: Color {
        Color(red: 0.2, green: 0.2, blue: 0.3)
    }
}
