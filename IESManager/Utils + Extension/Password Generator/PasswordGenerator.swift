//
//  PasswordGenerator.swift
//  IESManager
//
//  Created by Richard Stockdale on 28/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct PasswordGenerator {
    func newPassword() -> String {
        let wordList1 = getRandomWordList()
        let wordList2 = getRandomWordList()
        
        let wordList1Index = Int.random(in: 0..<wordList1.count - 1)
        let wordList2Index = Int.random(in: 0..<wordList2.count - 1)
        
        let w1 = wordList1[wordList1Index]
        let w2 = wordList2[wordList2Index]
        
        return "\(w1)-\(w2)-\(randomNumber())"
    }
    
    private func getRandomWordList() -> [String] {
        let randomInt = Int.random(in: 1..<6)
        return wordArray(number: randomInt)
    }
    
    private func wordArray(number: Int) -> [String] {
        if let filepath = Bundle.main.path(forResource: "\(number)", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents.components(separatedBy: "\n")
            } catch { fatalError("Could not load string array") }
        }
        else { fatalError("Could not find file in directory") }
    }
    
    private func randomNumber() -> String {
        let randomInt = Int.random(in: 11..<1000)
        return "\(randomInt)"
    }
    
    /// Utility method for checking for duplicate words. Do not call at run time
    private func checkForRepeatedWords() -> [String] {
        let a1 = wordArray(number: 1)
        let a2 = wordArray(number: 2)
        let a3 = wordArray(number: 3)
        let a4 = wordArray(number: 4)
        let a5 = wordArray(number: 5)

        let merged = a1 + a2 + a3 + a4 + a5

        let duplicates = Array(Set(merged.filter({ (i: String) in merged.filter({ $0 == i }).count > 1})))
        
        return duplicates
    }
}
