//
//  CupcakeCornerOrder.swift
//  100DaysOfSwiftUI
//
//  Created by Ho Lun Wan on 29/11/2024.
//

import Foundation

struct CupcakeCornerOrder: Equatable, Codable {
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 3
    var specialRequestEnabled = false
    var extraFrosting = false
    var addSprinkles = false
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    
    var hasValidAddress: Bool {
        let vals = [name, streetAddress, city, zip]
        for val in vals {
            if val.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
        }

        return true
    }
    
    var cost: Decimal {
        // $2 per cake
        var cost = Decimal(quantity) * 2

        // complicated cakes cost more
        cost += Decimal(type) / 2

        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }

        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }

        return cost
    }
}
