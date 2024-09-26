//
//  GuessTheFlagView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 26/9/2024.
//

import Foundation
import SwiftUI

struct GuessTheFlagView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var score = 0
    @State private var selectedAnswerIndex: Int?
    @State private var round = 1
    @State private var showCorrectAnswerAlert = false
    @State private var showWrongAnswerAlert = false
    @State private var showFinalAlert = false

    var body: some View {
        let countries = self.countries.prefix(3)

        return ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 400)
            
            VStack(spacing: 25) {
                Text("Guess the Flag")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(.secondary)
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(Array(zip(countries.indices, countries)), id: \.1) { idx, item in
                        Button {
                            onTapFlag(at: idx)
                        } label: {
                            Image("GuessTheFlag/\(item)")
                                .shadow(radius: 5)
                        }
                        .alert(
                            "It's correct!",
                            isPresented: $showCorrectAnswerAlert,
                            actions: {
                                Button("Continue") {
                                    round += 1
                                    prepareForNextRound()
                                    showCorrectAnswerAlert = false
                                }
                            }
                        )
                        .alert(
                            "Sorry, It's wrong!",
                            isPresented: $showWrongAnswerAlert,
                            actions: {
                                Button("Okay") {
                                    round += 1
                                    prepareForNextRound()
                                    showWrongAnswerAlert = false
                                }
                            },
                            message: {
                                Text("That's the flag of \(countries[selectedAnswerIndex ?? 0])")
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 40, trailing: 0))
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
            }
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea()
        .alert(
            "Good job!",
            isPresented: $showFinalAlert,
            actions: {
                Button("Restart") {
                    round = 1
                    prepareForNextRound()
                    showFinalAlert = false
                }
            },
            message: {
                Text("Your final score is \(score)")
            }
        )
    }
    
    private func onTapFlag(at idx: Int) {
        selectedAnswerIndex = idx
        if idx == correctAnswer {
            score += 1
            showCorrectAnswerAlert = true
        } else {
            showWrongAnswerAlert = true
        }
    }
    
    private func prepareForNextRound() {
        if round > 8 {
            showFinalAlert = true
        } else {
            countries.shuffle()
            correctAnswer = Int.random(in: 0...2)
            selectedAnswerIndex = nil
        }
    }
}

#Preview {
    NavigationStack {
        GuessTheFlagView()
    }
}
