//
//  GuessTheFlagView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 21/9/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct GuessTheFlagFeature {
    @CasePathable
    enum Alert: Equatable {
        case continueButtonTapped
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Alert>?
        var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"]
        var correctAnswer = Int.random(in: 0...2)
        var score = 0
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case tapFlag(Int)
        case reset
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .alert(.presented(.continueButtonTapped)):
                return .send(.reset)
            case .alert:
              return .none
            case let .tapFlag(idx):
                if idx == state.correctAnswer {
                    let score = state.score + 1
                    state.score = score
                    state.alert = AlertState {
                        TextState("It's correct!")
                    } actions: {
                        ButtonState(action: .continueButtonTapped) {
                            TextState("Continue")
                        }
                    }
                } else {
                    state.alert = AlertState {
                        TextState("Sorry, It's wrong!")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("Okay")
                        }
                    }
                }
                return .none
            case .reset:
                state.countries = state.countries.shuffled()
                state.correctAnswer = Int.random(in: 0...2)
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct GuessTheFlagView: View {
    @Bindable var store: StoreOf<GuessTheFlagFeature>
    
    var body: some View {
        let countries = store.countries.prefix(3)

        return ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Guess the Flag")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(.secondary)
                        Text(store.countries[store.correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(Array(zip(countries.indices, countries)), id: \.1) { idx, item in
                        Button {
                            store.send(.tapFlag(idx))
                        } label: {
                            Image("GuessTheFlag/\(item)")
                                .shadow(radius: 5)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 40, trailing: 0))
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Text("Score: \(store.score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
            }
            .padding(.horizontal, 16)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NavigationStack {
        GuessTheFlagView(
            store: Store(
                initialState: GuessTheFlagFeature.State(),
                reducer: { GuessTheFlagFeature() }
            )
        )
    }
}
