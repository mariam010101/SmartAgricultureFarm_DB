import Foundation
import Combine

class CropViewModel: ObservableObject {
    
    @Published var crops: [Crop] = []
    
    func loadCrops(search: String = "") {
        APIService.shared.fetchCrops(search: search) {
            self.crops = $0
        }
    }
    func addCrop(name: String, duration: Int) {
        APIService.shared.addCrop(name: name, duration: duration) {
            self.loadCrops()
        }
    }
    
    func deleteCrop(id: Int) {
        APIService.shared.deleteCrop(id: id) {
            self.loadCrops()
        }
    }
}

