import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct PunchRecord: Identifiable {
    var id: String
    var timestamp: Date
    var latitude: Double?
    var longitude: Double?
    var isEdited: Bool
}

class PunchViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var punchRecords = [PunchRecord]()
    var db = Firestore.firestore()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        fetchPunchRecords()
    }

    func fetchPunchRecords() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("punchRecords")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching records: \(error)")
                    return
                }
                
                if let snapshot = snapshot {
                    self.punchRecords = snapshot.documents.map { doc in
                        let data = doc.data()
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let latitude = data["latitude"] as? Double ?? 0.0
                        let longitude = data["longitude"] as? Double ?? 0.0
                        let isEdited = data["isEdited"] as? Bool ?? false
                        
                        return PunchRecord(id: doc.documentID, timestamp: timestamp, latitude: latitude, longitude: longitude, isEdited: isEdited)
                    }
                }
            }
    }

    func addPunchRecord() {
        
        let authorizationStatus = locationManager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            print("Localização não permitida. Solicitar permissão.")
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let punchRecord: [String: Any] = [
                "userId": userId,
                "timestamp": FieldValue.serverTimestamp(),
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "isEdited": false
            ]
            
            db.collection("punchRecords").addDocument(data: punchRecord) { error in
                if let error = error {
                    print("Error adding punch record: \(error)")
                } else {
                    print("Punch record added successfully")
                    self.fetchPunchRecords()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}

struct PunchView: View {
    @ObservedObject var viewModel = PunchViewModel()

    var body: some View {
        VStack {
            List {
                Section(header: Text("Últimos Registros").font(.headline)) {
                    ForEach(viewModel.punchRecords.prefix(5)) { record in
                        NavigationLink(destination: PunchDetailView(viewModel: PunchViewModel(), punchRecord: record)) {
                            VStack(alignment: .leading) {
                                Text("\(record.timestamp, formatter: dateFormatter)")
                            }
                        }
                    }
                }
            }
            
            
        }
        .navigationTitle("Início")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("PontoApp")
                        .font(.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .padding(4)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.addPunchRecord()
                    }) {
                        Image(systemName: "touchid")
                            .font(.title2)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}



struct SettingsView: View {
    var body: some View {
        Text("Configurações")
            .font(.headline)
            .padding()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = PunchViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                PunchView(viewModel: viewModel)
            }
            .tabItem {
                Label("Início", systemImage: "house")
            }
            .tag(0)
            
            NavigationView {
                RecordView(viewModel: viewModel) 
            }
            .tabItem {
                Label("Marcações", systemImage: "clock")
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Configurações", systemImage: "gearshape")
            }
            .tag(2)
        }
    }
}


private let onlyDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter
}()


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm - EEEE, dd/MM/yyyy"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
}()

#Preview {
    ContentView()
}
