//
//  iExpenseView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 10/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct iExpenseFeature {
    @ObservableState
    struct State: Equatable {
        var expenses = Expenses()
        @Presents var addExpense: iExpenseAddFeature.State?
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case removeItems(ExpenseItem.Kind, Set<UUID>)
        case addExpenseButtonTapped
        case addExpense(PresentationAction<iExpenseAddFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .removeItems(_, uuids):
                uuids.forEach { uuid in
                    if let idx = state.expenses.items.firstIndex(where: { $0.id == uuid }) {
                        state.expenses.items.remove(at: idx)
                    }
                }
                return .none
            case .addExpenseButtonTapped:
                state.addExpense = iExpenseAddFeature.State()
                return .none
            case let .addExpense(.presented(.delegate(delegateAction))):
                switch delegateAction {
                case let .saveExpense(item):
                    state.expenses.items.append(item)
                    state.addExpense = nil
                }
                return .none
            case .addExpense:
                return .none
            }
        }
        .ifLet(\.$addExpense, action: \.addExpense) {
            iExpenseAddFeature()
        }
    }
}

struct iExpenseView: View {
    private let sectionKinds: [ExpenseItem.Kind] = [.personal, .business]
    @Bindable var store: StoreOf<iExpenseFeature>
    
    var body: some View {
        List {
            ForEach(sectionKinds, id: \.self) { kind in
                if let items = store.expenses.groupedItems[kind] {
                    Section(kind.rawValue) {
                        ForEach(items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text(item.kind.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                ItemAmcountText(amount: item.amount)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            var uuids: Set<UUID> = []
                            indexSet.forEach {
                                uuids.insert(items[$0].id)
                            }
                            store.send(.removeItems(kind, uuids))
                        })
                    }
                }
            }
        }
        .navigationTitle("iExpense")
        .toolbar {
            Button("Add Expense", systemImage: "plus") {
                store.send(.addExpenseButtonTapped)
            }
        }
        .sheet(
            item: $store.scope(state: \.addExpense, action: \.addExpense)
        ) { addExpenseStore in
            NavigationStack {
                iExpenseAddView(store: addExpenseStore)
            }
        }
    }
}

struct ItemAmcountText: View {
    let amount: Double
    
    var body: some View {
        let text = Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            .font(.title2)
        switch amount {
        case ..<10:
            return text
        case ..<100:
            return text.foregroundColor(.yellow)
        default:
            return text.foregroundStyle(.red)
        }
    }
}

#Preview {
    NavigationStack {
        iExpenseView(
            store: Store(
                initialState: iExpenseFeature.State(),
                reducer: { iExpenseFeature() }
            )
        )
    }
}
