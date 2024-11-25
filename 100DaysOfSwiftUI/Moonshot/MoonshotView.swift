//
//  MoonshotView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 24/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoonshotFeature {
    @Reducer
    enum Destination {
        case mission(MoonshotMissionFeature)
    }
    
    @ObservableState
    struct State {
        let astronauts: [String: Astronaut] = (try? MoonshotHelper.loadFromFile("astronauts.json")) ?? [:]
        let missions: [Mission] = (try? MoonshotHelper.loadFromFile("missions.json")) ?? []
        @Presents var destination: Destination.State?
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case missionButtonTapped(Mission)
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
            case let .missionButtonTapped(mission):
                state.destination = .mission(
                    MoonshotMissionFeature.State(mission: mission, astronauts: state.astronauts)
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}


struct MoonshotView: View {
    @Bindable var store: StoreOf<MoonshotFeature>
    
    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 150))
        ]

        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(store.missions) { mission in
                    Button {
                        store.send(.missionButtonTapped(mission))
                    } label: {
                        VStack {
                            Image(mission.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding()
                            VStack {
                                Text(mission.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(mission.formattedLaunchDate)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(MoonshotTheme.lightBackground)
                        }
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(MoonshotTheme.lightBackground)
                        )
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Moonshot")
        .background(MoonshotTheme.darkBackground)
        .preferredColorScheme(.dark)
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.mission,
                action: \.destination.mission
            )
        ) { store in
            MoonshotMissionView(store: store)
        }
    }
}

#Preview {
    NavigationStack {
        MoonshotView(
            store: Store(
                initialState: MoonshotFeature.State(),
                reducer: { MoonshotFeature() }
            )
        )
    }
}
