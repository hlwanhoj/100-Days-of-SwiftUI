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
        case nextRoundButtonTapped
        case resetButtonTapped
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Alert>?
        var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]
        var correctAnswer = Int.random(in: 0...2)
        var tappedFlag: Int?
        var score = 0
        var round = 1
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case tapFlag(Int)
        case nextRound
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .alert(.presented(.nextRoundButtonTapped)):
                return .send(.nextRound)
            case .alert(.presented(.resetButtonTapped)):
                state.round = 0
                state.score = 0
                return .send(.nextRound)
            case .alert:
              return .none
            case let .tapFlag(idx):
                state.tappedFlag = idx
                if idx == state.correctAnswer {
                    let score = state.score + 1
                    state.score = score
                    state.alert = AlertState {
                        TextState("It's correct!")
                    } actions: {
                        ButtonState(action: .nextRoundButtonTapped) {
                            TextState("Continue")
                        }
                    }
                } else {
                    let countries = state.countries
                    state.alert = AlertState {
                        TextState("Sorry, It's wrong!")
                    } actions: {
                        ButtonState(action: .nextRoundButtonTapped) {
                            TextState("Continue")
                        }
                    } message: {
                        TextState("That's the flag of \(countries[idx])")
                    }
                }
                return .none
            case .nextRound:
                state.tappedFlag = nil
                if state.round >= 8 {
                    let score = state.score
                    state.alert = AlertState {
                        TextState("Good job!")
                    } actions: {
                        ButtonState(action: .resetButtonTapped) {
                            TextState("Continue")
                        }
                    } message: {
                        TextState("Your final score is \(score)")
                    }
                } else {
                    state.countries = state.countries.shuffled()
                    state.correctAnswer = Int.random(in: 0...2)
                    state.round += 1
                }
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
                        FlagImage(imageKey: "GuessTheFlag/\(item)", isSelected: store.tappedFlag.map { $0 == idx }) {
                            store.send(.tapFlag(idx))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 40, trailing: 0))
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    Text("Round: \(store.round)")
                        .foregroundStyle(.white)
                        .font(.title.bold())
                    Text("Score: \(store.score)")
                        .foregroundStyle(.white)
                        .font(.title.bold())
                }
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

struct FlagImage: View {
    let imageKey: String
    let isSelected: Bool?
    let action: @MainActor () -> Void
    @State private var animationAmount = 0.0
    
    var body: some View {
        Button {
            animationAmount += 360
            action()
        } label: {
            Image(imageKey)
                .shadow(radius: 5)
        }
        .opacity((isSelected ?? true) ? 1 : 0.25)
        .animation(isSelected == nil ? nil : .easeInOut(duration: 0.25), value: isSelected)
        .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(duration: 0.67, bounce: 0.5), value: animationAmount)
    }
}
