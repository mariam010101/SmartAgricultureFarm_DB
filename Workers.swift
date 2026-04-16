import Foundation

struct Sensor: Identifiable, Codable {
    let SensorID: Int
    let FieldID: Int
    let SensorType: String
    
    var id: Int { SensorID }
}
