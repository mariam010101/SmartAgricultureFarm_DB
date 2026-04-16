import Foundation

struct Worker: Identifiable, Codable {
    let WorkerID: Int
    let Name: String
    
    var id: Int { WorkerID }
}
