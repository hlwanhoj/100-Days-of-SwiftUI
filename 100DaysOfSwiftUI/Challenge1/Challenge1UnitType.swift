//
//  Challenge1UnitType.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 26/9/2024.
//

import Foundation

/// The operation for converting a unit.
enum Challenge1UnitOperation {
    case add(Double), multiple(Double)
}

/// Generic unit type for unit conversion.
protocol Challenge1UnitType: Hashable, Identifiable {
    /// The operations for converting a basis unit to this unit. For a basis unit the operations should be empty.
    var unitOperations: [Challenge1UnitOperation] { get }
}

extension Challenge1UnitType {
    var id: Self {
        self
    }
}
