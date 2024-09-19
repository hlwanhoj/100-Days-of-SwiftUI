//
//  Challenge1View.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 17/9/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture


enum UnitOperation {
    case add(Double), multiple(Double)
}

private enum Temperature: CaseIterable, Identifiable {
    case celsius, fahrenheit, kelvin
    
    var id: Self {
        self
    }
    
    var unitOperations: [UnitOperation] {
        return switch self {
        case .celsius:
            [.add(0)]
        case .fahrenheit:
            [.multiple(1.8), .add(32)]
        case .kelvin:
            [.add(273.15)]
        }
    }
}
private enum Length: CaseIterable {
    case meters, kilometers, feet, yards, miles
}
private enum Time: CaseIterable {
    case seconds, minutes, hours, days
}
private enum Volume: CaseIterable {
    case milliliters, liters, cups, pints, gallons
}

@Reducer
struct Challenge1Feature {
    enum Unit: CaseIterable, Identifiable {
        case temperature
        
        var id: Self {
            self
        }
    }
    
    @ObservableState
    struct State: Equatable {
        fileprivate let pickerOptions: [Temperature] = [.celsius, .fahrenheit, .kelvin]
        fileprivate var inputUnit: Temperature = .celsius
        var inputValue: Double = 0
        fileprivate var outputUnit: Temperature = .celsius
        
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

struct Challenge1View: View {
    @Bindable var store: StoreOf<Challenge1Feature>
    
    var body: some View {
        Form {
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
    
    private func nameForUnit(_ unit: Temperature) -> String {
        switch unit {
        case .celsius:
            "Celsius"
        case .fahrenheit:
            "Fahrenheit"
        case .kelvin:
            "Kelvin"
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
