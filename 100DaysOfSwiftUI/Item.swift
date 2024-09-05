//
//  Item.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 5/9/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}