//
//  Challenge1Units.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 26/9/2024.
//

import Foundation

enum Challenge1Temperature: Challenge1UnitType {
    case celsius, fahrenheit, kelvin
    
    var unitOperations: [Challenge1UnitOperation] {
        return switch self {
        case .celsius:
            []
        case .fahrenheit:
            [.multiple(1.8), .add(32)]
        case .kelvin:
            [.add(273.15)]
        }
    }
}

enum Challenge1Length: Challenge1UnitType {
    case meter, kilometer, foot, yard, mile
    
    var unitOperations: [Challenge1UnitOperation] {
        return switch self {
        case .meter:
            []
        case .kilometer:
            [.multiple(0.001)]
        case .foot:
            [.multiple(3.280839895)]
        case .yard:
            [.multiple(1 / 0.9144)]
        case .mile:
            [.multiple(1 / 1609.34)]
        }
    }
}

enum Challenge1Time: Challenge1UnitType {
    case second, minute, hour, day
    
    var unitOperations: [Challenge1UnitOperation] {
        return switch self {
        case .second:
            []
        case .minute:
            [.multiple(1 / 60)]
        case .hour:
            [.multiple(1 / 3600)]
        case .day:
            [.multiple(1 / 86400)]
        }
    }
}

enum Challenge1Volume: Challenge1UnitType {
    case milliliter, liter, cup, pint, gallon
    
    var unitOperations: [Challenge1UnitOperation] {
        switch self {
        case .milliliter:
            []
        case .liter:
            [.multiple(0.001)]
        case .cup:
            [.multiple(1 / 240)]
        case .pint:
            [.multiple(1 / 473.176)]
        case .gallon:
            [.multiple(1 / 3785.41)]
        }
    }
}
