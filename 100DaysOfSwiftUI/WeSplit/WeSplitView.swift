//
//  WeSplitView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 12/9/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WeSplitFeature {
    @ObservableState
    struct State: Equatable {
        var checkAmount: Double = 0.0
        var numberOfPeople: Int = 5
        var tipPercentage: Double = 0.20
        
        var total: Double {
            checkAmount * (1.0 + tipPercentage)
        }
        
        var totalPerPerson: Double {
            return total / Double(numberOfPeople)
        }
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        // Perform any other action here
        Reduce { state, action in
            switch action {
            case .binding(\.checkAmount):
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct WeSplitView: View {
    private let tipPercentages: [Double] = Array(0...100).map { Double($0) / 100 }
    @Bindable var store: StoreOf<WeSplitFeature>
    @FocusState private var amountIsFocused: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("Amount", value: $store.checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                Picker("Number of people", selection: $store.numberOfPeople) {
                    ForEach(2..<100) {
                        // Add tag here such that `numberOfPeople` can match the correct row
                        Text("\($0) people").tag($0)
                    }
                }
            }
            Section("How much tip do you want to leave?") {
                Picker("Tip percentage", selection: $store.tipPercentage) {
                    ForEach(tipPercentages, id: \.self) {
                        Text($0, format: .percent).tag($0)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            Section("Total Amount") {
                Text(store.total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
            Section("Amount per person") {
                Text(store.totalPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
        }
        .navigationTitle("WeSplit")
        .toolbar {
            if amountIsFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeSplitView(
            store: Store(
                initialState: WeSplitFeature.State(),
                reducer: { WeSplitFeature() }
            )
        )
    }
}
