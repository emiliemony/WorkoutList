import SwiftUI
import AVFoundation

// MARK: - ListItem Model

struct ListItem: Identifiable, Codable {
    var id = UUID()
    var firstInfo: String
    var secondInfo: String
    var unit: String
}

// MARK: - ListView

struct ContentView: View {
    @State private var items: [ListItem] = []
    @State private var firstInput: String = ""
    @State private var secondInput: String = ""
    @State private var isReps: Bool = true
    @State private var activeTimer: UUID? = nil
    @State private var remainingTime: Int = 0
    @State private var timer: Timer? = nil

    private let fileURL: URL = {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("items.json")
    }()

    var body: some View {
        NavigationView {
            VStack {
                Text("Workout")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    TextField("Exercise", text: $firstInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 140)

                    Button(action: {
                        isReps.toggle()
                    }) {
                        Image(systemName: isReps ? "dumbbell" : "clock")
                            .padding(.horizontal)
                            .frame(height: 36)
                            .foregroundColor(.blue)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }

                    TextField(isReps ? "Reps" : "Secs", text: $secondInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)

                    Button(action: addItem) {
                        Image(systemName: "plus")
                    }
                    .disabled(firstInput.isEmpty || secondInput.isEmpty)
                }
                .padding()

                List {
                    ForEach($items) { $item in
                        HStack(spacing: 12) {
                            TextField("Exercise", text: $item.firstInfo)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 140)

                            Spacer()

                            if item.unit == "Secs" {
                                Button(action: {
                                    toggleTimer(for: item)
                                }) {
                                    HStack(spacing: 2) {
                                        Image(systemName: "clock")
                                        if activeTimer == item.id {
                                            Text("\(remainingTime)s")
                                        }
                                    }
                                    .foregroundColor(.blue)
                                }
                            } else {
                                Image(systemName: "dumbbell")
                                    .foregroundColor(.blue)
                            }

                            Spacer()

                            TextField("Value", text: $item.secondInfo)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color("SecondaryBackground"))
                    }
                    .onDelete { offsets in
                        items.remove(atOffsets: offsets)
                        saveItems()
                    }
                    .onMove { source, destination in
                        items.move(fromOffsets: source, toOffset: destination)
                        saveItems()
                    }
                }
                .toolbar {
                    EditButton()
                }
                .scrollContentBackground(.hidden)
                .background(Color("PrimaryBackground"))
            }
            .background(Color("SecondaryBackground"))
            .onAppear(perform: loadItems)
        }
    }

    private func addItem() {
        items.append(ListItem(firstInfo: firstInput, secondInfo: secondInput, unit: isReps ? "Reps" : "Secs"))
        firstInput = ""
        secondInput = ""
        saveItems()
        hideKeyboard()
    }

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL)
        }
    }

    private func loadItems() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ListItem].self, from: data) else {
            return
        }
        items = decoded
    }

    private func toggleTimer(for item: ListItem) {
        if activeTimer == item.id {
            timer?.invalidate()
            activeTimer = nil
        } else {
            timer?.invalidate()
            remainingTime = Int(item.secondInfo) ?? 0
            activeTimer = item.id

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    AudioServicesPlaySystemSound(1021)
                    timer?.invalidate()
                    activeTimer = nil
                }
            }
        }
    }
}

// Keyboard dismiss helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
