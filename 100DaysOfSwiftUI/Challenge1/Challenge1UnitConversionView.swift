//
//  Challenge1UnitConversionView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 20/9/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

/// Feature for generic unit conversion
@Reducer
struct Challenge1UnitConversionFeature<T: Challenge1UnitType> {
    @ObservableState
    struct State: Equatable {
        let pickerOptions: [T]
        var inputUnit: T
        var inputValue: Double = 0
        var outputUnit: T
        
        var outputValue: Double {
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
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
    }
}

struct Challenge1UnitConversionView<T: Challenge1UnitType>: View {
    @Bindable var store: StoreOf<Challenge1UnitConversionFeature<T>>
    let nameForUnit: (T) -> String
    
    var body: some View {
        Section("Input") {
            Picker("Unit", selection: $store.inputUnit) {
                ForEach(store.pickerOptions) {
                    Text(nameForUnit($0)).tag($0)
                }
            }
            HStack {
                Text("Value")
                Spacer()
                TextField("Input Value", value: $store.inputValue, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
        }
        Section("Output") {
            Picker("Unit", selection: $store.outputUnit) {
                ForEach(store.pickerOptions) {
                    Text(nameForUnit($0)).tag($0)
                }
            }
            HStack {
                Text("Value")
                Spacer()
                Text(store.outputValue, format: .number)
            }
        }
        
    }
}

extension Challenge1UnitConversionView {
    static func create(
        pickerOptions: [T],
        inputUnit: T,
        outputUnit: T? = nil,
        nameForUnit: @escaping (T) -> String
    ) -> Challenge1UnitConversionView {
        Challenge1UnitConversionView<T>(
            store: Store(
                initialState: Challenge1UnitConversionFeature<T>.State(
                    pickerOptions: pickerOptions,
                    inputUnit: inputUnit,
                    outputUnit: outputUnit ?? inputUnit
                ),
                reducer: { Challenge1UnitConversionFeature() }
            ),
            nameForUnit: nameForUnit
        )
    }
}

#Preview {
    NavigationStack {
        Form {
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
        }
    }
}
