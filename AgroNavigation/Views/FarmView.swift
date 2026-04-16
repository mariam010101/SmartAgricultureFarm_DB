import SwiftUI
struct FarmView: View {
    
    @StateObject var viewModel = FarmViewModel()
    
    @State private var showAddFarm = false
    @State private var farmName = ""
    @State private var farmLocation = ""
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(viewModel.farms, id: \.id) { farm in
                HStack {
                    VStack(alignment: .leading) {
                        Text(farm.FarmName)
                        Text(farm.Location)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.deleteFarm(id: farm.FarmID, currentSearch: searchText)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Farms")
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            viewModel.loadFarms(search: searchText)
        }
        .toolbar {
            Button {
                showAddFarm = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .onAppear {
            viewModel.loadFarms()
        }
        .sheet(isPresented: $showAddFarm) {
            VStack(spacing: 16) {
                
                TextField("Farm Name", text: $farmName)
                TextField("Location", text: $farmLocation)
                
                Button("Add Farm") {
                    viewModel.addFarm(name: farmName, location: farmLocation)
                    
                    farmName = ""
                    farmLocation = ""
                    showAddFarm = false
                }
            }
            .padding()
            .frame(width: 300)
        }
    }
}
