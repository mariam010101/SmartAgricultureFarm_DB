enum MenuItem: String, CaseIterable, Identifiable {
    case farms
    case workers
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .farms: return "Farms"
        case .workers: return "Workers"
        }
    }
}
