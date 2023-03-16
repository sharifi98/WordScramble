//
//  ContentView.swift
//  WordScramble
//
//  Created by Hossein Sharifi on 14/03/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
       
        guard isOriginal(word: answer) else {
            wordError(title: "Word is already used", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word is not possible", message: "You cant spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You cant just make them up, you know!")
            return
        }
        
        guard isLongerThanThreeLetters(word: answer) else {
            wordError(title: "Word is too short", message: "The word must contain more than 2 letters")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    func startGame() {
        // 1. Fin the URL for start.txt in out app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load star.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string into an array of strings, splitting on the line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                // if  we are here everything worked, so we can exit
                return
            }
        }
        // If we are here then there was a problem - trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
        
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) && !(word == rootWord)
    }
    
    func isLongerThanThreeLetters(word: String) -> Bool {
        return (word.count > 2)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            // find the first index where the letter appears and assign it to pos
            if let pos = tempWord.firstIndex(of: letter) {
                
                // if the letter is found remove it from the tempWord so that it cant be used twice
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
