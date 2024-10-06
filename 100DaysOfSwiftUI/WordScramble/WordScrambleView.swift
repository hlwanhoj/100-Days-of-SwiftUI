//
//  WordScrambleView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 4/10/2024.
//

import SwiftUI

private enum WordScrambleError: Error {
    case fileNotFound, emptyList
    case addNewWord(title: String, message: String?)
}

struct WordScrambleView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("The word is")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(rootWord.capitalized)
                        .font(.title)
                }
                TextField("Enter your word", text: $newWord)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit(addNewWord)
                    .onAppear(perform: startGame)
            }
            
            Section {
                ForEach(usedWords, id: \.self) { word in
                    HStack {
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }
                }
            }
        }
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            if let msg = errorMessage {
                Text(msg)
            }
        }
        .navigationTitle("Word Scramble")
        .toolbar {
            Button("Restart") {
                startGame()
            }
        }
    }
    
    private func startGame() {
        usedWords.removeAll()
        do {
            guard let startWordsURL = Bundle.main.url(forResource: "word-scramble-list", withExtension: "txt") else {
                throw WordScrambleError.fileNotFound
            }
            
            let startWords = try String(contentsOf: startWordsURL)
            let allWords = startWords.components(separatedBy: "\n")
            guard let randomWord = allWords.randomElement() else {
                throw WordScrambleError.emptyList
            }
            
            rootWord = randomWord
        } catch {
            showWordError(title: "\(error)")
            rootWord = "silkworm"
        }
    }
    
    private func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !answer.isEmpty else { return }
        
        do {
            guard answer.count >= 3 else {
                throw WordScrambleError.addNewWord(title: "Word too short", message: "The word must be at least three characters long")
            }
            guard answer != rootWord else {
                throw WordScrambleError.addNewWord(title: "Word is root", message: "You can't use the root word")
            }
            guard isOriginalWord(answer) else {
                throw WordScrambleError.addNewWord(title: "Word used already", message: "Be more original")
            }
            guard isPossibleWord(answer) else {
                throw WordScrambleError.addNewWord(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            }
            guard isRealWord(answer) else {
                throw WordScrambleError.addNewWord(title: "Word not recognized", message: "You can't just make them up, you know!")
            }
            
            withAnimation {
                usedWords.insert(answer, at: 0)
            }
            newWord = ""
        } catch WordScrambleError.addNewWord(let title, let message) {
            showWordError(title: title, message: message)
        } catch {
            showWordError(title: "\(error)")
        }
    }
    
    private func showWordError(title: String, message: String? = nil) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    private func isOriginalWord(_ word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    private func isPossibleWord(_ word: String) -> Bool {
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
    
    private func isRealWord(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
}

#Preview {
    NavigationStack {
        WordScrambleView()
    }
}
