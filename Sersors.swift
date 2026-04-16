import Foundation
import SwiftUI
import Combine

class WorkerViewModel: ObservableObject {
    
    @Published var workers: [Worker] = []
    
    func loadWorkers(search: String = "") {
        APIService.shared.fetchWorkers(search: search) { result in
            self.workers = result
        }
    }
    
    func addWorker(name: String) {
        APIService.shared.addWorker(name: name) {
            self.loadWorkers()
        }
    }
    
    func deleteWorker(id: Int) {
        APIService.shared.deleteWorker(id: id) {
            self.loadWorkers()
        }
    }
}
