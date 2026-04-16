import Foundation

struct Farm: Identifiable, Codable {
    let FarmID: Int
    let FarmName: String
    let Location: String

    var id: Int { FarmID }
}

