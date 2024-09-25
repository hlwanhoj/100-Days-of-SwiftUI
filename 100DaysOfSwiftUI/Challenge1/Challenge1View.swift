//
//  Challenge1View.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 24/9/2024.
//

import SwiftUI

struct Challenge1View: View {
    enum Unit: Identifiable {
        case temperature, length, time, volume
        
        var id: Self {
            self
        }
    }
    
    @State var unit: Unit = .temperature
    
    var body: some View {
        Form {
            Section {
                Picker("Unit", selection: $unit) {
                    ForEach([Unit.temperature, Unit.length, Unit.time, Unit.volume]) {
                        Text(nameForUnit($0)).tag($0)
                    }
                }
            }
            switch unit {
            case .temperature:
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
            case .length:
                Challenge1UnitConversionView<Challenge1Length>(
                    pickerOptions: [.meter, .kilometer, .foot, .yard, .mile],
                    inputUnit: .meter,
                    outputUnit: .meter,
                    nameForUnit: { unit in
                        switch unit {
                        case .meter:
                            "Meter"
                        case .kilometer:
                            "Kilometer"
                        case .foot:
                            "Foot"
                        case .yard:
                            "Yard"
                        case .mile:
                            "Mile"
                        }
                    }
                )
            case .time:
                Challenge1UnitConversionView<Challenge1Time>(
                    pickerOptions: [.second, .minute, .hour, .day],
                    inputUnit: .second,
                    outputUnit: .second,
                    nameForUnit: { unit in
                        switch unit {
                        case .second:
                            "Second"
                        case .minute:
                            "Minute"
                        case .hour:
                            "Hour"
                        case .day:
                            "Day"
                        }
                    }
                )
            case .volume:
                Challenge1UnitConversionView<Challenge1Volume>(
                    pickerOptions: [.milliliter, .liter, .cup, .pint, .gallon],
                    inputUnit: .milliliter,
                    outputUnit: .milliliter,
                    nameForUnit: { unit in
                        switch unit {
                        case .milliliter:
                            "Milliliter"
                        case .liter:
                            "Liter"
                        case .cup:
                            "Cup"
                        case .pint:
                            "Pint"
                        case .gallon:
                            "Gallon"
                        }
                    }
                )
            }
        }
        .navigationTitle("Challenge 1")
    }
    
    private func nameForUnit(_ unit: Unit) -> String {
        switch unit {
        case .temperature:
            "Temperature"
        case .length:
            "Length"
        case .time:
            "Time"
        case .volume:
            "Volume"
        }
    }
}

#Preview {
    NavigationStack {
        Challenge1View()
    }
}
