import SwiftUI

struct WorkerView: View {
    
    @StateObject var viewModel = WorkerViewModel()
    @State private var searchText = ""
    @State private var showAddWorker = false
    @State private var workerName = ""
    
    var body: some View {
        List {
            ForEach(viewModel.workers) { worker in
                HStack {
                    Text(worker.Name)
                    
                    Spacer()
                    
                    Button {
                        viewModel.deleteWorker(id: worker.WorkerID)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Workers")
        
        .searchable(text: $searchText)
        
        .onSubmit(of: .search) {
            viewModel.loadWorkers(search: searchText)
        }
        .toolbar {
            Button {
                showAddWorker = true
            } label: {
                Image(systemName: "plus")
            }
        }
        
        .onAppear {
            viewModel.loadWorkers()
        }
        .sheet(isPresented: $showAddWorker) {
            VStack(spacing: 16) {
                
                TextField("Worker Name", text: $workerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add Worker") {
                    viewModel.addWorker(name: workerName)
                    
                    workerName = ""
                    showAddWorker = false
                }
            }
            .padding()
            .frame(width: 300)
        }
    }
}
