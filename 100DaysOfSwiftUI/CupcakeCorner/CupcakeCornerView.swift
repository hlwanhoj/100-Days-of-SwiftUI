//
//  CupcakeCornerView.swift
//  100DaysOfSwiftUI
//
//  Created by Ho Lun Wan on 29/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CupcakeCornerFeature {
    @Reducer
    enum Destination {
        case address(CupcakeCornerAddressFeature)
    }
    
    @ObservableState
    struct State {
        @Shared(.fileStorage(CupcakeCornerHelper.orderStoreUrl)) var order: CupcakeCornerOrder = CupcakeCornerOrder()
        @Presents var destination: Destination.State?
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case addressButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.order):
                if !state.order.specialRequestEnabled {
                    state.order.extraFrosting = false
                    state.order.addSprinkles = false
                }

                return .none
            case .binding:
                return .none
            case .destination:
                return .none
            case .addressButtonTapped:
                state.destination = .address(
                    CupcakeCornerAddressFeature.State(order: state.$order)
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct CupcakeCornerView: View {
    @Bindable var store: StoreOf<CupcakeCornerFeature>
    
    var body: some View {
        Form {
            Section {
                Picker("Select your cake type", selection: $store.order.type) {
                    ForEach(CupcakeCornerOrder.types.indices, id: \.self) {
                        Text(CupcakeCornerOrder.types[$0])
                    }
                }
                
                Stepper("Number of cakes: \(store.order.quantity)", value: $store.order.quantity, in: 3...20)
            }
            Section {
                Toggle("Any special requests?", isOn: $store.order.specialRequestEnabled)

                if store.order.specialRequestEnabled {
                    Toggle("Add extra frosting", isOn: $store.order.extraFrosting)

                    Toggle("Add extra sprinkles", isOn: $store.order.addSprinkles)
                }
            }
            Section {
                Button("Delivery details") {
                    store.send(.addressButtonTapped)
                }
            }
        }
        .navigationTitle("Cupcake Corner")
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.address,
                action: \.destination.address
            )
        ) { store in
            CupcakeCornerAddressView(store: store)
        }
    }
}

#Preview {
    NavigationStack {
        CupcakeCornerView(
            store: Store(
                initialState: CupcakeCornerFeature.State(),
                reducer: { CupcakeCornerFeature() }
            )
        )
    }
}
