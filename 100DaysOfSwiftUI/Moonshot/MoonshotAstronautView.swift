//
//  MoonshotAstronautView.swift
//  100DaysOfSwiftUI
//
//  Created by Ho Lun Wan on 25/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoonshotAstronautFeature {
    @ObservableState
    struct State {
        let astronaut: Astronaut
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

struct MoonshotAstronautView: View {
    @Bindable var store: StoreOf<MoonshotAstronautFeature>

    var body: some View {
        ScrollView {
            VStack {
                Image(store.astronaut.imageId)
                    .resizable()
                    .scaledToFit()
                
                Text(store.astronaut.description)
                    .padding()
            }
        }
        .background(MoonshotTheme.darkBackground)
        .navigationTitle(store.astronaut.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let astronauts: [String: Astronaut] = (try? MoonshotHelper.loadFromFile("astronauts.json")) ?? [:]
    return NavigationStack {
        MoonshotAstronautView(
            store: Store(
                initialState: MoonshotAstronautFeature.State(
                    astronaut: astronauts["aldrin"]!
                ),
                reducer: { MoonshotAstronautFeature() }
            )
        )
            .preferredColorScheme(.dark)
    }
}
