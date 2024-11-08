//
//  WordScrambleView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 4/10/2024.
//

import SwiftUI
import ComposableArchitecture

private enum WordScrambleError: Error {
    case fileNotFound, emptyList
    case addNewWord(title: String, message: String?)
}

@Reducer
struct WordScrambleFeature {
    @CasePathable
    enum Alert: Equatable {
    }
    
    @ObservableState
    struct State: Equatable {
        var usedWords = [String]()
        var rootWord = ""
        var newWord = ""
        @Presents var alert: AlertState<Alert>?
        
        func isOriginalWord(_ word: String) -> Bool {
            !usedWords.contains(word)
        }
        
        func isPossibleWord(_ word: String) -> Bool {
            var tempWord = rootWord
            
            for letter in word {
                if let pos = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: pos)
                } else {
                    return false
                }
            }
            
            return true
        }
        
        func isRealWord(_ word: String) -> Bool {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return misspelledRange.location == NSNotFound
        }
    }
    
    // `BindableAction` can let properties in state bindable to UI
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case startGame
        case addNewWord
    }
    
    private func showAlert(_ state: inout WordScrambleFeature.State, title: String, message: String? = nil) {
        state.alert = AlertState(title: {
            TextState(title)
        }, actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        }, message: message.map { str in
            {
                TextState(str)
            }
        })
    }
    
    private func startGame(_ state: inout WordScrambleFeature.State) {
        state.usedWords.removeAll()
        do {
            guard let startWordsURL = Bundle.main.url(forResource: "word-scramble-list", withExtension: "txt") else {
                throw WordScrambleError.fileNotFound
            }
            
            let startWords = try String(contentsOf: startWordsURL)
            let allWords = startWords.components(separatedBy: "\n")
            guard let randomWord = allWords.randomElement() else {
                throw WordScrambleError.emptyList
            }
            
            state.rootWord = randomWord
        } catch {
            showAlert(&state, title: "\(error)")
            state.rootWord = "silkworm"
        }
    }
    
    private func addNewWord(_ state: inout WordScrambleFeature.State) {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = state.newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !answer.isEmpty else { return }
        
        do {
            guard answer.count >= 3 else {
                throw WordScrambleError.addNewWord(title: "Word too short", message: "The word must be at least three characters long")
            }
            guard answer != state.rootWord else {
                throw WordScrambleError.addNewWord(title: "Word is root", message: "You can't use the root word")
            }
            guard state.isOriginalWord(answer) else {
                throw WordScrambleError.addNewWord(title: "Word used already", message: "Be more original")
            }
            guard state.isPossibleWord(answer) else {
                throw WordScrambleError.addNewWord(title: "Word not possible", message: "You can't spell that word from '\(state.rootWord)'!")
            }
            guard state.isRealWord(answer) else {
                throw WordScrambleError.addNewWord(title: "Word not recognized", message: "You can't just make them up, you know!")
            }
            
            withAnimation {
                state.usedWords.insert(answer, at: 0)
            }
            state.newWord = ""
        } catch WordScrambleError.addNewWord(let title, let message) {
            showAlert(&state, title: title, message: message)
        } catch {
            showAlert(&state, title: "\(error)")
        }
    }
    
    var body: some ReducerOf<Self> {
        // `BindingReducer` is needed when `BindableAction` is used
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .alert:
                return .none
            case .startGame:
                startGame(&state)
                return .none
            case .addNewWord:
                addNewWord(&state)
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct WordScrambleView: View {
    @Bindable var store: StoreOf<WordScrambleFeature>
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("The word is")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(store.rootWord.capitalized)
                        .font(.title)
                }
                TextField("Enter your word", text: $store.newWord)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        store.send(.addNewWord)
                    }
            }
            
            Section {
                ForEach(store.usedWords, id: \.self) { word in
                    HStack {
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }
                }
            }
        }
        .navigationTitle("Word Scramble")
        .toolbar {
            Button("Restart") {
                store.send(.startGame)
            }
        }
        .onAppear {
            store.send(.startGame)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NavigationStack {
        WordScrambleView(
            store: Store(
                initialState: WordScrambleFeature.State(),
                reducer: { WordScrambleFeature() }
            )
        )
    }
}
