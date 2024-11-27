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
        var isShowingGrid = true
        @Presents var destination: Destination.State?
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case missionButtonTapped(Mission)
        case listButtonTapped
        case gridButtonTapped
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
            case .listButtonTapped:
                state.isShowingGrid = false
                return .none
            case .gridButtonTapped:
                state.isShowingGrid = true
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}


struct MoonshotView: View {
    @Bindable var store: StoreOf<MoonshotFeature>
    
    var body: some View {
        return Group {
            if store.isShowingGrid {
                MoonshotGridView(missions: store.missions) { mission in
                    store.send(.missionButtonTapped(mission))
                }
            } else {
                MoonshotListView(missions: store.missions) { mission in
                    store.send(.missionButtonTapped(mission))
                }
            }
        }
        .navigationTitle("Moonshot")
        .toolbar {
            if store.isShowingGrid {
                Button("Change to List", systemImage: "list.bullet") {
                    store.send(.listButtonTapped)
                }
                .tint(Color.white)
            } else {
                Button("Change to Grid", systemImage: "square.grid.2x2") {
                    store.send(.gridButtonTapped)
                }
                .tint(Color.white)
            }
        }
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

private struct MoonshotGridView: View {
    let missions: [Mission]
    let action: (Mission) -> Void
    
    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 150))
        ]
        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(missions) { mission in
                    Button {
                        action(mission)
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
    }
}

private struct MoonshotListView: View {
    let missions: [Mission]
    let action: (Mission) -> Void
    
    var body: some View {
        List(missions) { mission in
            Button {
                action(mission)
            } label: {
                HStack(spacing: 16) {
                    Image(mission.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    VStack(alignment: .leading) {
                        Text(mission.displayName)
                            .font(.headline)
                        Text(mission.formattedLaunchDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
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
