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
                    print("Erro ao buscar registros: \(error)")
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
                    print("Erro ao salvar os dados: \(error)")
                } else {
                    print("Dados registardos com sucesso")
                    self.fetchPunchRecords()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao solicitar permissao de localização: \(error.localizedDescription)")
    }
}

struct PunchView: View {
    @ObservedObject var viewModel = PunchViewModel()
    @State private var userName: String = "Usuário"
    @State private var currentDate = Date()
    @State private var showConfirmationAlert = false
    let primaryColor = Color(hex: "5300FF")


    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Text("Olá, \(userName)")
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                
                Text("Data e Hora: \(currentDate, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            .onAppear(perform: fetchUserName)
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
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .cornerRadius(8)
                    Text("PontoApp")
                        .font(.title2)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .padding(4)
                    
                    Spacer()
                    
                    Button(action: {
                        showConfirmationAlert = true
                    }) {
                        Image(systemName: "touchid")
                            .padding(8)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showConfirmationAlert) {
                        Alert(
                            title: Text("Confirmar Registro de Ponto"),
                            message: Text("Data e Hora: \(currentDate, formatter: dateFormatter)"),
                            primaryButton: .default(Text("Confirmar")) {
                                viewModel.addPunchRecord()
                            },
                            secondaryButton: .cancel(Text("Cancelar"))
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            currentDate = Date()
            
        }
    }
    
    func fetchUserName() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["fullName"] as? String ?? "Usuário"
            } else {
                print("Erro ao buscar nome do usuário: \(error?.localizedDescription ?? "Desconhecido")")
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = PunchViewModel()
    let primaryColor = Color(hex: "5300FF")
    
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
                    .foregroundStyle(primaryColor)
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
