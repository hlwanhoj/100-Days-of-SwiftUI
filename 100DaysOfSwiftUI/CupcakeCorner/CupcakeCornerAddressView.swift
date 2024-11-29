//
//  CupcakeCornerAddressView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 1/12/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CupcakeCornerAddressFeature {
    @Reducer
    enum Destination {
        case checkout(CupcakeCornerCheckoutFeature)
    }
    
    @ObservableState
    struct State {
        @Shared(.fileStorage(CupcakeCornerHelper.orderStoreUrl)) var order: CupcakeCornerOrder = CupcakeCornerOrder()
        @Presents var destination: Destination.State?
        
        init(order: Shared<CupcakeCornerOrder>) {
            self._order = order
        }
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case checkoutButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .destination:
                return .none
            case .checkoutButtonTapped:
                state.destination = .checkout(
                    CupcakeCornerCheckoutFeature.State(order: state.$order)
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct CupcakeCornerAddressView: View {
    @Bindable var store: StoreOf<CupcakeCornerAddressFeature>

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $store.order.name)
                TextField("Street Address", text: $store.order.streetAddress)
                TextField("City", text: $store.order.city)
                TextField("Zip", text: $store.order.zip)
            }

            Section {
                Button("Check out") {
                    store.send(.checkoutButtonTapped)
                }
                .disabled(!store.order.hasValidAddress)
            }
        }
        .navigationTitle("Delivery details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.checkout,
                action: \.destination.checkout
            )
        ) { store in
            CupcakeCornerCheckoutView(store: store)
        }
    }
}

#Preview {
    NavigationStack {
        CupcakeCornerAddressView(
            store: Store(
                initialState: CupcakeCornerAddressFeature.State(order: Shared(CupcakeCornerOrder())),
                reducer: { CupcakeCornerAddressFeature() }
            )
        )
    }
}
