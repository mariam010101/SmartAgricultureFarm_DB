import Foundation
import Combine

class SensorViewModel: ObservableObject {
    
    @Published var sensors: [Sensor] = []
    
    func loadSensors(search: String = "") {
        APIService.shared.fetchSensors(search: search) {
            self.sensors = $0
        }
    }
    
    func deleteSensor(id: Int) {
        APIService.shared.deleteSensor(id: id) {
            self.loadSensors()
        }
    }
    
    func addSensor(fieldID: Int, type: String) {
        APIService.shared.addSensor(fieldID: fieldID, type: type) {
            self.loadSensors()
        }
    }
}
