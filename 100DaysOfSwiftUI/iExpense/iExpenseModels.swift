//
//  iExpenseModels.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 24/11/2024.
//

import Foundation

struct ExpenseItem: Identifiable, Equatable, Codable {
    enum Kind: String, Codable {
        case business = "Business"
        case personal = "Personal"
    }
    
    var id = UUID()
    let name: String
    let kind: Kind
    let amount: Double
}

@Observable
class Expenses: Equatable {
    var items: [ExpenseItem] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "iExpense.items") {
            if let decoded = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                items = decoded
                return
            }
        }
        items = []
    }
    
    static func == (lhs: Expenses, rhs: Expenses) -> Bool {
        return lhs.items == rhs.items
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "iExpense.items")
        }
    }
    
    var groupedItems: [ExpenseItem.Kind: [ExpenseItem]] {
        Dictionary(grouping: items, by: \.kind)
    }
}
