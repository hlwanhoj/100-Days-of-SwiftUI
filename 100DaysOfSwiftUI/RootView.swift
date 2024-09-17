//
//  RootView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 11/9/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct RootFeature {
    @Reducer
    enum Path {
        case weSplit(WeSplitFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        // ...
    }
    enum Action {
        case path(StackActionOf<Path>)
        // ...
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Core logic for root feature
            return .none
        }
        .forEach(\.path, action: \.path)
    }
}

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            List {
                NavigationLink(
                    state: RootFeature.Path.State.weSplit(WeSplitFeature.State())
                ) {
                    Text("WeSplit")
                }
                Text("A Second List Item")
                Text("A Third List Item")
            }
            .navigationTitle("Menu")
        } destination: { store in
            switch store.case {
            case let .weSplit(store):
                WeSplitView(store: store)
            }
        }
    }
}

//struct RootView: View {
//}

#Preview {
    RootView(
        store: Store(
            initialState: RootFeature.State(),
            reducer: { RootFeature() }
        )
    )
}
