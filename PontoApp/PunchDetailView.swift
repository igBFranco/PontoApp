//
//  PunchDetailView.swift
//  PontoApp
//
//  Created by Igor Bueno Franco on 08/10/24.
//

import SwiftUI
import MapKit
import FirebaseAuth


struct PunchDetailView: View {
    @ObservedObject var viewModel: PunchViewModel
    @State var punchRecord: PunchRecord
    
    @State private var editedDate = Date()
    @State private var isEditing = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @Environment(\.presentationMode) var presentationMode
    

    var body: some View {
        ScrollView {
            VStack {
                Text("Registro Ponto")
                    .font(.largeTitle)
                    .padding()
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text("Data e Hora: \(editedDate, formatter: dateFormatter)")
                        .font(.headline)
                        .padding()
                }
                
                if isEditing {
                    DatePicker("Data e Hora", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .padding()
                    Button(action: {
                        saveEditedRecord()
                    }) {
                        Text("Salvar Alterações")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                if let latitude = punchRecord.latitude, let longitude = punchRecord.longitude {
                    Text("Localização")
                    
                    Map(coordinateRegion: $region, annotationItems: [punchRecord]) { record in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: record.latitude ?? 0.0, longitude: record.longitude ?? 0.0))
                    }
                    .frame(height: 300)
                    .onAppear {
                        setMapRegion(latitude: latitude, longitude: longitude)
                    }
                } else {
                    Text("Dados de Localização não disponíveis")
                        .padding()
                }
                if punchRecord.isEdited {
                    Text("Este registro foi editado")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            editedDate = punchRecord.timestamp
            viewModel.fetchPunchRecords()
        }
        .padding()
    }

    private func setMapRegion(latitude: Double, longitude: Double) {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    private func saveEditedRecord() {        
        let updatedRecord: [String: Any] = [
            "timestamp": editedDate,
            "isEdited": true
        ]
        
        viewModel.db.collection("punchRecords").document(punchRecord.id).updateData(updatedRecord) { error in
            if let error = error {
                print("Erro ao salvar o registro editado: \(error)")
            } else {
                print("Registro editado com sucesso.")
                viewModel.fetchPunchRecords()
                if let index = viewModel.punchRecords.firstIndex(where: { $0.id == punchRecord.id }) {
                    viewModel.punchRecords[index].timestamp = editedDate
                    viewModel.punchRecords[index].isEdited = true
                }
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm - EEEE, dd/MM/yyyy"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
}()
