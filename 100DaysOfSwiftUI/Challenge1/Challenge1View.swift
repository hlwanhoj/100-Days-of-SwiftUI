//
//  Challenge1View.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 17/9/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct Challenge1Feature {
    enum Unit: Identifiable {
        case temperature, length, time, volume
        
        var id: Self {
            self
        }
    }
    
    @ObservableState
    struct State: Equatable {
        var unit: Unit = .temperature
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
    }
}

struct Challenge1View: View {
    private typealias Unit = Challenge1Feature.Unit
    
    @Bindable var store: StoreOf<Challenge1Feature>
    
    var body: some View {
        Form {
            Section {
                Picker("Unit", selection: $store.unit) {
                    ForEach([Unit.temperature, Unit.length, Unit.time, Unit.volume]) {
                        Text(nameForUnit($0)).tag($0)
                    }
                }
            }
            switch store.unit {
            case .temperature:
                Challenge1UnitConversionView<Challenge1Temperature>.create(
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
                Challenge1UnitConversionView<Challenge1Length>.create(
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
                Challenge1UnitConversionView<Challenge1Time>.create(
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
                Challenge1UnitConversionView<Challenge1Volume>.create(
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
        Challenge1View(
            store: Store(
                initialState: Challenge1Feature.State(),
                reducer: { Challenge1Feature() }
            )
        )
    }
}
