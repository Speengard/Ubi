//
//  TestSummaryView.swift
//  SS24
//
//  Created by Riccardo Di Stefano on 24/02/24.
//

import Foundation
import SwiftUI
import Charts

struct TestSummaryView: View {
    
    var test: Test!
    var tests: [Test]!
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("Taken on " + test.takenDate.formatted(date: .abbreviated, time: .omitted))
                    .padding()
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: UIColor.systemGray))
                Spacer()
            }
            Form {
                Section {
                    HStack{
                        Text("first excersize result")
                        Spacer()
                        Text(String(test.firstTestResult))
                    }
                }
                Section {
                    HStack{
                        Text("second excersize result")
                        Spacer()
                        Text(String(test.secondTestResult))
                    }
                }
                Section {
                    HStack{
                        Text("third excersize result")
                        Spacer()
                        Text(String(test.thirdTestResult))
                    }
                }
            
            }
            
        }
        .navigationTitle(test.name)
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    TestSummaryView(test: Test(hasDoneFirstTest: true, hasDoneSecondTest: true, name: "Test #1", firstTestResult: 70, secondTestResult: 80, takenDate: Date()))
}

