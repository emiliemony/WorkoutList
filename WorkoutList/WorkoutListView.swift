import SwiftUI
import AVFoundation

// MARK: - ListItem Model
struct ListItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var firstInfo: String
    var secondInfo: String
    var unit: String
}

// MARK: - Home View
let defaultWorkoutTitle = "Emilie's Workout"

struct ContentView: View {
    private let titlesURL: URL = {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("workoutTitles.json")
    }()

    @State private var workoutTitles: [String] = [defaultWorkoutTitle]
    @State private var newWorkoutTitle: String = ""
    @State private var showingAdd: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // Header
                VStack(spacing: 12) {
                    Text("Workouts")
                        .font(.largeTitle).bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    Image("HeaderImage")
                        .resizable().scaledToFit().frame(height: 100).cornerRadius(20)
                }
                .padding(.vertical, 20)
                .background(Color("SecondaryBackground"))

                // Workout list
                List {
                    ForEach(workoutTitles, id: \.self) { title in
                        NavigationLink(destination: WorkoutListView(workoutTitle: title)) {
                            Text(title)
                        }
                    }
                    .onDelete { offsets in
                        workoutTitles.remove(atOffsets: offsets)
                        saveTitles()
                    }
                }
                .listStyle(.plain).scrollContentBackground(.hidden)
                .background(Color("PrimaryBackground"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showingAdd = true } label: { Image(systemName: "plus") }
                    }
                }
                .alert("New Workout", isPresented: $showingAdd) {
                    TextField("Workout name", text: $newWorkoutTitle)
                    Button("Add", action: addTitle)
                    Button("Cancel", role: .cancel) { newWorkoutTitle = "" }
                } message: { Text("Enter a name for your new workout list.") }
            }
            .onAppear(perform: loadTitles)
            .background(Color("PrimaryBackground"))
        }
    }

    private func addTitle() {
        let trimmed = newWorkoutTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !workoutTitles.contains(trimmed) else { return }
        workoutTitles.append(trimmed)
        newWorkoutTitle = ""
        saveTitles()
    }

    private func saveTitles() {
        if let data = try? JSONEncoder().encode(workoutTitles) {
            try? data.write(to: titlesURL)
        }
    }

    private func loadTitles() {
        if let data = try? Data(contentsOf: titlesURL),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            workoutTitles = decoded
        } else {
            workoutTitles = [defaultWorkoutTitle]
        }
    }
}

// MARK: - WorkoutListView
struct WorkoutListView: View {
    let workoutTitle: String

    @State private var items: [ListItem] = []
    @State private var firstInput: String = ""
    @State private var secondInput: String = ""
    @State private var isReps: Bool = true

    @State private var activeTimer: UUID? = nil
    @State private var remainingTime: Int = 0
    @State private var timer: Timer? = nil
    @Environment(\.editMode) private var editMode

    private var localURL: URL {
        let manager = FileManager.default
        return manager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("\(workoutTitle).json")
    }

    var body: some View {
        VStack {
            Text(workoutTitle)
                .font(.largeTitle).bold().foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color("SecondaryBackground"))

            HStack {
                TextField("Exercise", text: $firstInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 170)
                Button { isReps.toggle() } label: {
                    Image(systemName: isReps ? "dumbbell" : "clock")
                        .padding(.horizontal).frame(height: 36)
                        .background(Color.blue.opacity(0.2)).cornerRadius(8)
                }
                TextField(isReps ? "Reps" : "Secs", text: $secondInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 60)
                Button { addItem() } label: { Image(systemName: "plus") }
                    .disabled(firstInput.isEmpty || secondInput.isEmpty)
            }
            .padding()

            List {
                ForEach($items) { $item in
                    HStack(spacing: 12) {
                        TextField("Exercise", text: $item.firstInfo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 170)
                            .onChange(of: item.firstInfo) {
                                saveItems()
                            }

                        Spacer()

                        if item.unit == "Secs" {
                            Button {
                                toggleTimer(for: item)
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                    if activeTimer == item.id {
                                        Text("\(remainingTime)")
                                            .foregroundColor(Color("SalmonBackground"))
                                    }
                                }
                            }
                        } else {
                            Image(systemName: "dumbbell")
                                .foregroundColor(.blue)
                        }

                        Spacer()

                        TextField("Value", text: $item.secondInfo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                            .onChange(of: item.secondInfo) {
                                saveItems()
                            }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color("SecondaryBackground"))
                }

                .onDelete { offsets in items.remove(atOffsets: offsets); saveItems() }
                .onMove { src, dst in items.move(fromOffsets: src, toOffset: dst); saveItems() }
            }
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { EditButton() } }
            .scrollContentBackground(.hidden).background(Color("PrimaryBackground"))
            .onAppear(perform: loadItems)

            if editMode?.wrappedValue.isEditing == true {
                Button("Reset", action: resetToDefault)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
    }

    private func addItem() {
        items.append(ListItem(firstInfo: firstInput, secondInfo: secondInput, unit: isReps ? "Reps" : "Secs"))
        firstInput = ""; secondInput = ""; saveItems(); hideKeyboard()
    }

    private func loadItems() {
        let fm = FileManager.default
        if fm.fileExists(atPath: localURL.path),
           let data = try? Data(contentsOf: localURL),
           let decoded = try? JSONDecoder().decode([ListItem].self, from: data) {
            items = decoded
        } else if let bundleURL = Bundle.main.url(forResource: workoutTitle, withExtension: "json"),
                  let data = try? Data(contentsOf: bundleURL),
                  let decoded = try? JSONDecoder().decode([ListItem].self, from: data) {
            items = decoded
            // save default locally
            if let saveData = try? JSONEncoder().encode(decoded) {
                try? saveData.write(to: localURL)
            }
        } else {
            items = []
        }
    }

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: localURL)
        }
    }

    private func resetToDefault() {
        if let bundleURL = Bundle.main.url(forResource: workoutTitle, withExtension: "json"),
           let data = try? Data(contentsOf: bundleURL),
           let decoded = try? JSONDecoder().decode([ListItem].self, from: data) {
            items = decoded
            if let saveData = try? JSONEncoder().encode(decoded) {
                try? saveData.write(to: localURL)
            }
        }
    }

    private func toggleTimer(for item: ListItem) {
        if activeTimer == item.id { timer?.invalidate(); activeTimer = nil }
        else {
            timer?.invalidate(); remainingTime = Int(item.secondInfo) ?? 0; activeTimer = item.id
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                remainingTime -= 1
                if remainingTime <= 0 { AudioServicesPlaySystemSound(1021); timer?.invalidate(); activeTimer = nil }
            }
        }
    }
}

extension View { func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}}
