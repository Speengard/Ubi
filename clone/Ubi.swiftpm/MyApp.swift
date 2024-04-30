import SwiftUI

@main
struct MyApp: App {
    let mainVM = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(VM: self.mainVM)
        }
    }
}
