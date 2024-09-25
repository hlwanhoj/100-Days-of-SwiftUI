//
//  Challenge1UnitConversionView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 26/9/2024.
//

import Foundation
import SwiftUI

private struct Challenge1UnitConversion {
    static func outputValue<T: Challenge1UnitType>(
        inputUnit: T,
        inputValue: Double,
        outputUnit: T
    ) -> Double {
        var output = inputValue
        
        // Do nothing as there is no conversion needed
        if inputUnit == outputUnit {
            return output
        }
        
        for operation in inputUnit.unitOperations.reversed() {
            switch operation {
            case let .add(value):
                output -= value
            case let .multiple(value):
                output /= value
            }
        }
        
        for operation in outputUnit.unitOperations {
            switch operation {
            case let .add(value):
                output += value
            case let .multiple(value):
                output *= value
            }
        }
        
        return output
    }
}

struct Challenge1UnitConversionView<T: Challenge1UnitType>: View {
    let pickerOptions: [T]
    @State var inputUnit: T
    @State var inputValue: Double = 0
    @State var outputUnit: T
    let nameForUnit: (T) -> String
    
    private var outputValue: Double {
        Challenge1UnitConversion.outputValue(
            inputUnit: inputUnit,
            inputValue: inputValue,
            outputUnit: outputUnit
        )
    }
    
    var body: some View {
        Section("Input") {
            Picker("Unit", selection: $inputUnit) {
                ForEach(pickerOptions) {
                    Text(nameForUnit($0)).tag($0)
                }
            }
            HStack {
                Text("Value")
                Spacer()
                TextField("Input Value", value: $inputValue, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
        }
        Section("Output") {
            Picker("Unit", selection: $outputUnit) {
                ForEach(pickerOptions) {
                    Text(nameForUnit($0)).tag($0)
                }
            }
            HStack {
                Text("Value")
                Spacer()
                Text(outputValue, format: .number)
                    .foregroundStyle(.secondary)
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        Form {
            Challenge1UnitConversionView<Challenge1Temperature>(
                pickerOptions: [.celsius, .fahrenheit, .kelvin],
                inputUnit: .celsius,
                outputUnit: .celsius,
                nameForUnit: { unit in
                    switch unit {
                    case .celsius:
                        "Celsius (°C)"
                    case .fahrenheit:
                        "Fahrenheit (°F)"
                    case .kelvin:
                        "Kelvin (K)"
                    }
                }
            )
        }
    }
}
