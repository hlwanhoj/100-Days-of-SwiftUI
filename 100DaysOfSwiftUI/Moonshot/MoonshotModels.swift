//
//  MoonshotModels.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 24/11/2024.
//

import Foundation

struct Astronaut: Decodable, Identifiable {
    let id: String
    let name: String
    let description: String
    
    var imageId: String {
        "Moonshot/\(id)"
    }
}

struct Mission: Decodable, Identifiable {
    struct CrewRole: Decodable {
        let name: String
        let role: String
    }
    
    let id: Int
    let launchDate: Date?
    let crew: [CrewRole]
    let description: String
    
    var displayName: String {
        "Apollo \(id)"
    }

    var image: String {
        "Moonshot/apollo\(id)"
    }
    
    var formattedLaunchDate: String {
        launchDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"
    }
}
