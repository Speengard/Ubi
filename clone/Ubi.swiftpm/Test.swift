//
//  Test.swift
//  SS24
//
//  Created by Riccardo Di Stefano on 24/02/24.
//

import Foundation

struct Test: Identifiable, Encodable, Decodable{
    
    var id: UUID = UUID()
    
    var hasDoneFirstTest = false
    var hasDoneSecondTest = false
    var hasDoneThirdTest = false
    var isComplete = false
    
    var name: String = ""
    
    var firstTestResult: Double = 0.0
    var secondTestResult: Double = 0.0
    var thirdTestResult: Double = 0.0

    var takenDate: Date = Date()

    init(id: UUID = UUID(), hasDoneFirstTest: Bool = false, hasDoneSecondTest: Bool = false, isComplete: Bool = true, name: String, firstTestResult: Double, secondTestResult: Double, takenDate: Date) {
        self.id = id
        self.hasDoneFirstTest = hasDoneFirstTest
        self.hasDoneSecondTest = hasDoneSecondTest
        self.isComplete = isComplete
        self.name = name
        self.firstTestResult = firstTestResult
        self.secondTestResult = secondTestResult
        self.takenDate = takenDate
    }
    
    init() {
        
    }
}


