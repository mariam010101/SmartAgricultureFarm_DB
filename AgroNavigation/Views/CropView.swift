import SwiftUI

struct CropView: View {
    
    @StateObject var viewModel = CropViewModel()
    @State private var searchText = ""
    @State private var showAddCrop = false
    @State private var cropName = ""
    @State private var duration = ""
    
    var body: some View {
        List {
            ForEach(viewModel.crops) { crop in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(crop.CropName)
                            .font(.headline)
                        
                        Text("Growth: \(crop.GrowthDuration) days")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.deleteCrop(id: crop.CropID)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Crops")
        
        .searchable(text: $searchText)
        
        .onSubmit(of: .search) {
            viewModel.loadCrops(search: searchText)
        }
        .toolbar {
            Button {
                showAddCrop = true
            } label: {
                Image(systemName: "plus")
            }
        }
        
        .onAppear {
            viewModel.loadCrops()
        }
        .sheet(isPresented: $showAddCrop) {
            VStack(spacing: 16) {
                
                TextField("Crop Name", text: $cropName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Growth Duration", text: $duration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add Crop") {
                    viewModel.addCrop(
                        name: cropName,
                        duration: Int(duration) ?? 0
                    )
                    
                    cropName = ""
                    duration = ""
                    showAddCrop = false
                }
            }
            .padding()
            .frame(width: 300)
        }
    }
}

