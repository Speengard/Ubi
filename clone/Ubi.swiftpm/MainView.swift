//
//  MainView.swift
//  SS24
//
//  Created by Riccardo Di Stefano on 21/02/24.
//

import Foundation
import SwiftUI

struct MainView: View {
    
    @StateObject var VM: MainViewModel
    @State var newTest: Test = Test()
    
    @State private var isPresentingInputName = false
    @State private var enteredName: String = ""
    @State private var isNavigationActive = false
    
    var body: some View {
        NavigationStack {
            Form(content: {
                Button {
                    isPresentingInputName.toggle()
                } label: {
                    Text("create a new test!")
                        .foregroundStyle(Color.black)
                }
                .alert("New Test", isPresented: $isPresentingInputName) {
                    TextField(VM.placeHolderString, text: $enteredName)
                        .textInputAutocapitalization(.never)
                    Button("OK", action: setTestNameAndNavigate)
                    Button("Cancel", role: .cancel) {
                        resetTestName()
                        isPresentingInputName.toggle()
                    }
                } message: {
                    Text("add a name for the new test!")
                }
                
                
                if !self.VM.tests.filter({!$0.isComplete}).isEmpty {
                    Section {
                        ForEach(self.$VM.tests.filter({!$0.wrappedValue.isComplete}),id: \.id) { $test in
                            NavigationLink {
                                //summary test view
                                NewTestView(test: $test, VM: VM)
                            }label: {
                                Text(test.name).bold()
                            }
                        }
                        
                    }header: {
                        Text("Undergoing Tests")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.black)
                            .textCase(nil)
                    }
                }
                
                if !self.VM.tests.filter({$0.isComplete}).isEmpty {
                    Section {
                        ForEach(self.VM.tests.filter({$0.isComplete}),id: \.id) { test in
                            NavigationLink {
                                //summary test view
                                TestSummaryView(test: test, tests: self.VM.tests)
                            }label: {
                                Text(test.name).bold()
                            }
                        }
                        
                    } header: {
                        Text("Past Tests")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.black)
                            .textCase(nil)
                    }
                }
            })
            .navigationTitle("Ubi")
            .onAppear {
                VM.saveToDisk()
            }
            
        }
        .preferredColorScheme(.light)
    }
    
    private func setTestNameAndNavigate() {
        if self.enteredName == "" {
            self.$newTest.wrappedValue.name = self.VM.placeHolderString
        }else {
            self.$newTest.wrappedValue.name = enteredName
        }
        
        self.VM.appendTest(newValue: newTest)
        self.$enteredName.wrappedValue = ""
        self.isNavigationActive = true
        self.newTest = Test()
        
    }
    
    private func resetTestName() {
        self.$newTest.wrappedValue.name = ""
        self.$enteredName.wrappedValue = ""
    }
}


#Preview {
    MainView(VM: MainViewModel())
}
