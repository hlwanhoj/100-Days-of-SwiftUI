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
        case challenge1(Challenge1Feature)
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
                NavigationLink(
                    state: RootFeature.Path.State.challenge1(Challenge1Feature.State())
                ) {
                    Text("Challenge 1")
                }
            }
            .navigationTitle("Menu")
        } destination: { store in
            switch store.case {
            case let .weSplit(store):
                WeSplitView(store: store)
            case let .challenge1(store):
                Challenge1View(store: store)
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
