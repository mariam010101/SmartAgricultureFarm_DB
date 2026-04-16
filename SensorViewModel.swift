import SwiftUI
import Foundation
import Combine

class FarmViewModel: ObservableObject {
    
    @Published var farms: [Farm] = []
    
    func addFarm(name: String, location: String) {
        APIService.shared.addFarm(name: name, location: location) {
            self.loadFarms()
        }
    }
    
    func deleteFarm(id: Int, currentSearch: String) {
        APIService.shared.deleteFarm(id: id) {
            
            DispatchQueue.main.async {
                // 🔥 сразу убираем из UI
                self.farms.removeAll { $0.FarmID == id }
            }
            
            // 🔥 обновляем список
            self.loadFarms(search: currentSearch)
        }
    }
    
    func loadFarms(search: String = "") {
        
        var urlString = "\(APIService.shared.baseURL)/farms"
        
        if !search.isEmpty {
            let encoded = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "?search=\(encoded)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            if let data = data {
                let farms = try? JSONDecoder().decode([Farm].self, from: data)
                
                DispatchQueue.main.async {
                    self.farms = farms ?? []
                }
            }
            
        }.resume()
    }
}
