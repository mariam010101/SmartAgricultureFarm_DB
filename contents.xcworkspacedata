import SwiftUI

struct SensorView: View {
    
    @StateObject var viewModel = SensorViewModel()
    
    @State private var searchText = ""
    @State private var showAdd = false
    @State private var fieldID = ""
    @State private var type = ""
    
    var body: some View {
        List {
            ForEach(viewModel.sensors) { sensor in
                HStack {
                    VStack(alignment: .leading) {
                        Text(sensor.SensorType)
                            .font(.headline)
                        
                        Text("Field: \(sensor.FieldID)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.deleteSensor(id: sensor.SensorID)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Sensors")
        
        .searchable(text: $searchText)
        
        .onSubmit(of: .search) {
            viewModel.loadSensors(search: searchText)
        }
        
        .toolbar {
            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
            }
        }
        
        .onAppear {
            viewModel.loadSensors()
        }
        
        .sheet(isPresented: $showAdd) {
            VStack(spacing: 16) {
                
                TextField("Field ID", text: $fieldID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Sensor Type", text: $type)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add Sensor") {
                    viewModel.addSensor(
                        fieldID: Int(fieldID) ?? 0,
                        type: type
                    )
                    
                    fieldID = ""
                    type = ""
                    showAdd = false
                }
            }
            .padding()
            .frame(width: 300)
        }
    }
}

