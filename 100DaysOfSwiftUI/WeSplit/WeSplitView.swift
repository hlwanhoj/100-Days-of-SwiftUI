//
//  WeSplitView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 23/9/2024.
//

import SwiftUI

struct WeSplitView: View {
    let tipPercentages = [0, 0.05, 0.10, 0.15, 0.20, 0.25,]
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 0.2
    @FocusState private var amountIsFocused: Bool
    
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    private var totalAmount: Double {
        checkAmount * (1 + tipPercentage)
    }
    private var totalPerPerson: Double {
        totalAmount / Double(numberOfPeople)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Amount", value: $checkAmount, format: .currency(code: currencyCode))
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button("Done") {
                                amountIsFocused = false
                            }
                        }
                    }
                Picker("Number of people", selection: $numberOfPeople) {
                    ForEach(2..<100) {
                        Text("\($0) people").tag($0)
                    }
                }
            }
            Section("How much tip do you want to leave?") {
                Picker("Tip percentage", selection: $tipPercentage) {
                    ForEach(tipPercentages, id: \.self) {
                        Text($0, format: .percent)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Total amount") {
                Text(totalAmount, format: .currency(code: currencyCode))
            }
            Section("Amount per person") {
                Text(totalPerPerson, format: .currency(code: currencyCode))
            }
        }
        .navigationTitle("WeSplit")
    }
}

#Preview {
    NavigationStack {
        WeSplitView()
    }
}
