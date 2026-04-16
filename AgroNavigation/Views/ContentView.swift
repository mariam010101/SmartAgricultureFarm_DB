import SwiftUI

struct ContentView: View {
    
    @State private var selectedPage: String? = "farms"
    
    var body: some View {
        NavigationSplitView {
            
            List(selection: $selectedPage) {
                
                NavigationLink("Farms", value: "farms")
                    .tag("farms")
                
                NavigationLink("Workers", value: "workers")
                    .tag("workers")
                
                NavigationLink("Crops", value: "crops")
                    .tag("crops")
                
                NavigationLink("Sensors", value: "sensors") // 👈 ВОТ ЭТО ДОБАВЬ
                    .tag("sensors")
            }
            .navigationTitle("Menu")
            
        } detail: {
            switch selectedPage {
                
            case "workers":
                WorkerView()
                
            case "crops":
                CropView()
                
            case "sensors":
                SensorView()
                
            default:
                FarmView()
            }
        }
    }
}
