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
    @ObservableState
    struct State {
        struct CrewMember {
            let role: String
            let astronaut: Astronaut
        }
        
        let mission: Mission
        let crews: [CrewMember]
        
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
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
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
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(MoonshotTheme.lightBackground)
                    .padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Mission Highlights")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                    
                    Text(store.mission.description)
                }
                .padding(.horizontal)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(MoonshotTheme.lightBackground)
                    .padding(.vertical)

                VStack(alignment: .leading) {
                    Text("Crew")
                        .font(.title.bold())
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(store.crews, id: \.role) { crewMember in
                            NavigationLink {
                                Text("Astronaut details")
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
            .padding(.bottom)
        }
        .navigationTitle(store.mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(MoonshotTheme.darkBackground)
    }
}

#Preview {
    let missions: [Mission] = (try? MoonshotHelper.loadFromFile("missions.json")) ?? []
    let astronauts: [String: Astronaut] = (try? MoonshotHelper.loadFromFile("astronauts.json")) ?? [:]
    
    return NavigationStack {
        MoonshotMissionView(
            store: Store(
                initialState: MoonshotMissionFeature.State(
                    mission: missions[0],
                    astronauts: astronauts
                ),
                reducer: { MoonshotMissionFeature() }
            )
        )
        .preferredColorScheme(.dark)
    }
}
