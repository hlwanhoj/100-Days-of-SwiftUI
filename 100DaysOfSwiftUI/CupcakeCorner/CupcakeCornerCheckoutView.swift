//
//  CupcakeCornerCheckoutView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 1/12/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CupcakeCornerCheckoutFeature {
    @CasePathable
    enum Alert: Equatable {
    }
    
    @ObservableState
    struct State {
        @Shared(.fileStorage(CupcakeCornerHelper.orderStoreUrl)) var order: CupcakeCornerOrder = CupcakeCornerOrder()
        @Presents var alert: AlertState<Alert>?

        init(order: Shared<CupcakeCornerOrder>) {
            self._order = order
        }
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case placeOrderButtonTapped
        case showOrderConfirmation(String)
        case showError(Error)
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .alert:
                return .none
            case .placeOrderButtonTapped:
                let order = state.order
                return .run { send in
                    print("Place Order")
                    do {
                        let confirmedOrder = try await placeOrder(order: order)
                        await send(.showOrderConfirmation("Your order for \(confirmedOrder.quantity)x \(CupcakeCornerOrder.types[confirmedOrder.type].lowercased()) cupcakes is on its way!"))
                    } catch {
                        await send(.showError(error))
                    }
                }
            case let .showOrderConfirmation(message):
                state.alert = AlertState {
                    TextState("Thank you!")
                } message: {
                    TextState(message)
                }
                return .none
            case let .showError(error):
                state.alert = getAlertState(for: error)
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    private func getAlertState(for error: Error) -> AlertState<Alert> {
        AlertState {
            TextState("Error")
        } message: {
            TextState(error.localizedDescription)
        }
    }
    
    private func placeOrder(order: CupcakeCornerOrder) async throws -> CupcakeCornerOrder {
        let encoded = try JSONEncoder().encode(order)
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        let decodedOrder = try JSONDecoder().decode(CupcakeCornerOrder.self, from: data)
        return decodedOrder
    }
}

struct CupcakeCornerCheckoutView: View {
    @Bindable var store: StoreOf<CupcakeCornerCheckoutFeature>
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total is \(store.order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place Order") {
                    store.send(.placeOrderButtonTapped)
                }
                .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NavigationStack {
        CupcakeCornerCheckoutView(
            store: Store(
                initialState: CupcakeCornerCheckoutFeature.State(order: Shared(CupcakeCornerOrder())),
                reducer: { CupcakeCornerCheckoutFeature() }
            )
        )
    }
}
