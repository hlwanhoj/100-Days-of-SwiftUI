//
//  MoonshotMissionView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 24/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoonshotMissionFeature {
    @Reducer
    enum Destination {
        case astronaut(MoonshotAstronautFeature)
    }

    @ObservableState
    struct State {
        struct CrewMember {
            let role: String
            let astronaut: Astronaut
        }
        
        let mission: Mission
        let crews: [CrewMember]
        @Presents var destination: Destination.State?
        
        init(mission: Mission, astronauts: [String: Astronaut]) {
            self.mission = mission
            
            self.crews = mission.crew.compactMap { member in
                if let astronaut = astronauts[member.name] {
                    return CrewMember(role: member.role, astronaut: astronaut)
                } else {
                    return nil
                }
            }
        }
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case astronautButtonTapped(Astronaut)
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
            case let .astronautButtonTapped(astronaut):
                state.destination = .astronaut(
                    MoonshotAstronautFeature.State(astronaut: astronaut)
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct MoonshotMissionView: View {
    @Bindable var store: StoreOf<MoonshotMissionFeature>
    
    var body: some View {
        ScrollView {
            VStack {
                Image(store.mission.image)
                    .resizable()
                    .scaledToFit()
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.6
                    }
                    .padding(.top)
                
                MoonshotMissionSeparatorView()
                
                VStack(alignment: .leading) {
                    Text("Mission Highlights")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                    
                    Text(store.mission.description)
                    Spacer(minLength: 29)

                    Text("Launch Date")
                        .font(.title2.bold())
                    Text(store.mission.launchDate?.formatted(date: .long, time: .omitted) ?? "N/A")
                        .foregroundStyle(.white.opacity(0.66))
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                MoonshotMissionSeparatorView()

                VStack(alignment: .leading) {
                    Text("Crew")
                        .font(.title.bold())
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                MoonshotMissionAstronautsView(crews: store.crews) { astronaut in
                    store.send(.astronautButtonTapped(astronaut))
                }
            }
            .padding(.bottom)
        }
        .navigationTitle(store.mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(MoonshotTheme.darkBackground)
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.astronaut,
                action: \.destination.astronaut
            )
        ) { store in
            MoonshotAstronautView(store: store)
        }
    }
}

private struct MoonshotMissionAstronautsView: View {
    let crews: [MoonshotMissionFeature.State.CrewMember]
    let action: (Astronaut) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(crews, id: \.role) { crewMember in
                    Button {
                        action(crewMember.astronaut)
                    } label: {
                        HStack {
                            Image(crewMember.astronaut.imageId)
                                .resizable()
                                .frame(width: 104, height: 72)
                                .clipShape(.capsule)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(.white, lineWidth: 1)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(crewMember.astronaut.name)
                                    .foregroundStyle(.white)
                                    .font(.headline)
                                Text(crewMember.role)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct MoonshotMissionSeparatorView: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundStyle(MoonshotTheme.lightBackground)
            .padding(.vertical)
    }
}

#Preview {
    let missions: [Mission] = (try? MoonshotHelper.loadFromFile("missions.json")) ?? []
    let astronauts: [String: Astronaut] = (try? MoonshotHelper.loadFromFile("astronauts.json")) ?? [:]
    
    return NavigationStack {
        MoonshotMissionView(
            store: Store(
                initialState: MoonshotMissionFeature.State(
                    mission: missions[1],
                    astronauts: astronauts
                ),
                reducer: { MoonshotMissionFeature() }
            )
        )
        .preferredColorScheme(.dark)
    }
}
