import Foundation

class APIService {
    
    static let shared = APIService()
    
    let baseURL = "http://127.0.0.1:8000"
    
    func fetchFarms(completion: @escaping ([Farm]) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/farms") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                print("❌ ERROR:", error)
                return
            }
            
            if let data = data {
                let farms = try? JSONDecoder().decode([Farm].self, from: data)
                
                DispatchQueue.main.async {
                    completion(farms ?? [])
                }
            }
            
        }.resume()
    }
    
    func addFarm(name: String, location: String, completion: @escaping () -> Void) {
        
        guard let url = URL(string: "\(baseURL)/farms") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "FarmName": name,
            "Location": location
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            
            if let error = error {
                print("❌ ADD ERROR:", error)
                return
            }
            
            DispatchQueue.main.async {
                completion()
            }
            
        }.resume()
    }
    
    func deleteFarm(id: Int, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(baseURL)/farms/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        print("🗑 DELETE:", url)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            
            if let error = error {
                print("❌ DELETE ERROR:", error)
                return
            }
            
            DispatchQueue.main.async {
                completion()
            }
            
        }.resume()
    }
    // MARK: - WORKERS

    func fetchWorkers(completion: @escaping ([Worker]) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/workers") else { return }
        
        print("👉 WORKERS REQUEST:", url)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                print("❌ WORKERS ERROR:", error)
                return
            }
            
            if let data = data {
                print("📦 WORKERS RAW:", String(data: data, encoding: .utf8) ?? "")
                
                let workers = try? JSONDecoder().decode([Worker].self, from: data)
                
                DispatchQueue.main.async {
                    completion(workers ?? [])
                }
            }
            
        }.resume()
    }
    // 🔹 GET workers
    func fetchWorkers(search: String = "", completion: @escaping ([Worker]) -> Void) {
        
        var urlString = "\(baseURL)/workers"
        
        if !search.isEmpty {
            urlString += "?search=\(search)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            if let data = data {
                let workers = try? JSONDecoder().decode([Worker].self, from: data)
                
                DispatchQueue.main.async {
                    completion(workers ?? [])
                }
            }
            
        }.resume()
    }
    
    func addWorker(name: String, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(baseURL)/workers")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "Name": name
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }

    // 🔹 DELETE worker
    func deleteWorker(id: Int, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(baseURL)/workers/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }
    
    
    
    // 🔹 GET crops
    func fetchCrops(search: String = "", completion: @escaping ([Crop]) -> Void) {
        
        var urlString = "\(baseURL)/crops"
        
        if !search.isEmpty {
            urlString += "?search=\(search)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            if let data = data {
                let crops = try? JSONDecoder().decode([Crop].self, from: data)
                
                DispatchQueue.main.async {
                    completion(crops ?? [])
                }
            }
            
        }.resume()
    }
    
    func addCrop(name: String, duration: Int, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(baseURL)/crops")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "CropName": name,
            "GrowthDuration": duration
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }

    // 🔹 DELETE crop
    func deleteCrop(id: Int, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(baseURL)/crops/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }
    
    // 🔹 GET sensors
    func fetchSensors(search: String = "", completion: @escaping ([Sensor]) -> Void) {
        
        var urlString = "\(baseURL)/sensors"
        
        if !search.isEmpty {
            urlString += "?search=\(search)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            if let data = data {
                let sensors = try? JSONDecoder().decode([Sensor].self, from: data)
                
                DispatchQueue.main.async {
                    completion(sensors ?? [])
                }
            }
            
        }.resume()
    }

    // 🔹 DELETE sensor
    func deleteSensor(id: Int, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(baseURL)/sensors/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }

    // 🔹 ADD sensor
    func addSensor(fieldID: Int, type: String, completion: @escaping () -> Void) {
        
        let url = URL(string: "\(baseURL)/sensors")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "FieldID": fieldID,
            "SensorType": type
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }
}
