//
//  MainViewController.swift
//  SS24
//
//  Created by Riccardo Di Stefano on 24/02/24.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var tests: [Test] = [] { didSet {
        self.saveToDisk()
        setPlaceHolderString()
    }}
    
    @Published var placeHolderString = "" {
        didSet {
            print("placeHolderString changed to: \(placeHolderString)")
        }
    }
    
    public func setPlaceHolderString() {
        print("count: \(self.tests.count)")
        self.placeHolderString = "Test #" + String(self.tests.count + 1)
        print("placeholderString: \(self.placeHolderString)")
    }
    
    init(){
        self.readFromDisk()
    }
    
    public func appendTest(newValue: Test) {
        withAnimation {
            print("animation")
            tests.append(newValue)
        }
    }
    
    
    public func saveToDisk() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("tests.json")
        
        do{
            let testsJSON = try encoder.encode(tests)
            
            try testsJSON.write(to: fileURL,options: .atomic)
        }catch {
            assertionFailure("can't encode tests")
        }
        
    }
    
    public func readFromDisk() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("tests.json").path
        var jsonData = Data()
        
        if FileManager.default.fileExists(atPath: filePath), let data = FileManager.default.contents(atPath: filePath) {
            jsonData = data
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do{
            self.tests = try decoder.decode([Test].self, from: jsonData)
        }catch{
            self.tests = []
        }
    }
}
