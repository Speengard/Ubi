//
//  NewTestView.swift
//  SS24
//
//  Created by Riccardo Di Stefano on 24/02/24.
//

import Foundation
import SwiftUI

struct NewTestView: View {
    @Binding var test: Test
    @ObservedObject var VM: MainViewModel
    
    var body: some View {
        NavigationStack {
            VStack{
                Form {
                    Section {
                        Text("The finger coordination exercise involves a sequential and controlled touch movement specifically designed for the left hand. In this exercise, the user is prompted to touch each of their left-hand fingers onto the left thumb in a systematic order. The movement starts with the left index finger, progresses through the middle, ring, and little fingers, and concludes with a touch to the thumb. The exercise encourages a steady and intentional motion, focusing on the left hand's fine motor skills. By engaging in this activity regularly, users can enhance left-hand finger coordination, refine their dexterity, and improve overall precision in finger movements, contributing to a heightened level of left-hand motor proficiency.")
                        
                        if(!test.hasDoneFirstTest){

                            NavigationLink {
                                FirstExcersizeHVC(test: $test).ignoresSafeArea(.all)
                            } label: {
                                Text("First")
                            }
                            
                        }else {
                            HStack{
                                Text("First")
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.green)
                            }
                        }
                    }
                    
                    Section {
                        Text("The finger coordination exercise targets the right hand, emphasizing a sequential and controlled touch movement. Users are prompted to touch their right-hand fingers to the right thumb in a specific order. The exercise commences with the right index finger, followed by the middle, ring, and little fingers, concluding with a touch to the thumb. The objective is to maintain a steady and deliberate motion throughout. This exercise is tailored to enhance the fine motor skills of the right hand, focusing on precision and dexterity. Regular practice can lead to improved right-hand finger coordination, contributing to an overall refinement of motor skills and increased proficiency in executing precise finger movements.")
                        if(!test.hasDoneSecondTest) {
                            NavigationLink {
                                SecondExcersizeHVC(test: $test).ignoresSafeArea(.all)
                            } label: {
                                Text("Second")
                            }
                        }else {
                            HStack {
                                Text("Second")
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.green)
                            }
                        }
                    }
                    
                    Section {
                        Text("The coordination exercise involves a simultaneous drag movement with both fingers, tracing a path from the bottom to the top. In this activity, users are required to maintain synchronicity as they move their fingers in a coordinated manner along the specified path. The exercise challenges bilateral coordination, requiring the user to control both fingers simultaneously. The bottom-to-top motion encourages a steady and balanced movement, fostering improved control and alignment of both hands. This exercise not only assesses the user's ability to coordinate both hands in unison but also promotes enhanced fine motor skills and precision in executing dual-finger movements. Regular practice of this exercise can contribute to heightened bilateral coordination and improved motor proficiency.")
                        if(!test.hasDoneThirdTest) {
                            NavigationLink {
                                ThirdExcersizeHVC(test: $test).ignoresSafeArea(.all)
                            } label: {
                                Text("Third")
                            }
                        }else {
                            HStack {
                                Text("Third")
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.green)
                            }
                        }
                    }
                }
            }
            .onAppear(perform: {
                print(test.name)
                VM.saveToDisk()
            })
            
            .onDisappear(){
                VM.saveToDisk()
            }
            .navigationTitle(test.name)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}


#Preview {
    NewTestView(test: .constant(Test(hasDoneFirstTest: true,hasDoneSecondTest: true, name: "Test!", firstTestResult: 100, secondTestResult: 100, takenDate: Date())), VM: MainViewModel())
}
