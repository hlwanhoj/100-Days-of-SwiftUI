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
        case guessTheFlag(GuessTheFlagFeature)
        case betterRest(BetterRestFeature)
        case wordScramble(WordScrambleFeature)
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
                NavigationLink(
                    state: RootFeature.Path.State.guessTheFlag(GuessTheFlagFeature.State())
                ) {
                    Text("Guess The Flag")
                }
                NavigationLink(
                    state: RootFeature.Path.State.betterRest(BetterRestFeature.State())
                ) {
                    Text("BetterRest")
                }
                NavigationLink(
                    state: RootFeature.Path.State.wordScramble(WordScrambleFeature.State())
                ) {
                    Text("Word Scramble")
                }
            }
            .navigationTitle("Menu")
        } destination: { store in
            switch store.case {
            case let .weSplit(store):
                WeSplitView(store: store)
            case let .challenge1(store):
                Challenge1View(store: store)
            case let .guessTheFlag(store):
                GuessTheFlagView(store: store)
            case let .betterRest(store):
                BetterRestView(store: store)
            case let .wordScramble(store):
                WordScrambleView(store: store)
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
