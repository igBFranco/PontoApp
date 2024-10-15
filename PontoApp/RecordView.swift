//
//  RecordView.swift
//  PontoApp
//
//  Created by Igor Bueno Franco on 13/10/24.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var viewModel: PunchViewModel

    var groupedRecords: [String: [PunchRecord]] {
        groupPunchRecords(viewModel.punchRecords)
    }

    var body: some View {
            List {
                ForEach(groupedRecords.keys.sorted(), id: \.self) { date in
                    Section(header: Text(date).font(.headline)) {
                        ForEach(groupedRecords[date] ?? []) { record in
                            NavigationLink(destination: PunchDetailView(viewModel: viewModel, punchRecord: record)) {
                                RecordRow(record: record)
                            }
                        }
                    }
                }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image(uiImage: UIImage(named: "Icon") ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("PontoApp")
                        .font(.title2)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .padding(4)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    func groupPunchRecords(_ records: [PunchRecord]) -> [String: [PunchRecord]] {
        Dictionary(grouping: records) { record in
            onlyDateFormatter.string(from: record.timestamp)
        }
    }
}

struct RecordRow: View {
    var record: PunchRecord

    var body: some View {
        HStack() {
            Text("\(record.timestamp, formatter: dateFormatter)")
            Spacer()
            if record.isEdited {
                Text("E")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.orange)
                    .cornerRadius(5)
            } else {
                Text("O")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
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
    formatter.dateFormat = "HH:mm"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
}()
