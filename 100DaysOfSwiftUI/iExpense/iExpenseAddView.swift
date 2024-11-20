//
//  iExpenseAddView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 23/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct iExpenseAddFeature {
    @ObservableState
    struct State: Equatable {
        var name = ""
        var kind: ExpenseItem.Kind = .personal
        var amount = 0.0
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        enum Delegate: Equatable {
            case saveExpense(ExpenseItem)
        }
        
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case saveButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .delegate:
                return .none
            case .saveButtonTapped:
                let item = ExpenseItem(name: state.name, kind: state.kind, amount: state.amount)
                return .send(.delegate(.saveExpense(item)))
            }
        }
    }
}

struct iExpenseAddView: View {
    @Bindable var store: StoreOf<iExpenseAddFeature>
    
    let kinds: [ExpenseItem.Kind] = [.business, .personal]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $store.name)
                
                Picker("Type", selection: $store.kind) {
                    ForEach(kinds, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                
                TextField("Amount", value: $store.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add new expense")
        }
        .toolbar {
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
    }
}

#Preview {
    NavigationStack {
        iExpenseAddView(
            store: Store(
                initialState: iExpenseAddFeature.State(),
                reducer: { iExpenseAddFeature() }
            )
        )
    }
}
