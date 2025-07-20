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
struct ContentView: View {
    // File location for the list of workout titles
    private let fileURL: URL = {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("workoutTitles.json")
    }()

    @State private var workoutTitles: [String] = ["Emilie's Core Workout"]
    @State private var newWorkoutTitle: String = ""
    @State private var showingAdd: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // Header (title + icon)
                VStack(spacing: 12) {
                    Text("Workouts")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)

                    Image("HeaderImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .cornerRadius(20)
                }
                .padding(.vertical, 20)
                .background(Color("SecondaryBackground"))

                // List of workouts
                List {
                    ForEach(workoutTitles, id: \.self) { title in
                        NavigationLink(destination: WorkoutListView(workoutTitle: title)) {
                            Text(title)
                        }
                    }
                    .onDelete { offsets in
                        workoutTitles.remove(atOffsets: offsets)
                        saveWorkoutTitles()
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color("PrimaryBackground"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAdd = true }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
                .alert("New Workout", isPresented: $showingAdd) {
                    TextField("Workout name", text: $newWorkoutTitle)
                    Button("Add") { addWorkout() }
                    Button("Cancel", role: .cancel) { newWorkoutTitle = "" }
                } message: {
                    Text("Enter a name for your new workout list.")
                }
            }
            .onAppear { loadWorkoutTitles() }
            .background(Color("PrimaryBackground"))
        }
    }

    private func addWorkout() {
        let trimmed = newWorkoutTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !workoutTitles.contains(trimmed) else { return }
        workoutTitles.append(trimmed)
        newWorkoutTitle = ""
        saveWorkoutTitles()
    }

    private func saveWorkoutTitles() {
        if let data = try? JSONEncoder().encode(workoutTitles) {
            try? data.write(to: fileURL)
        }
    }

    private func loadWorkoutTitles() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            workoutTitles = decoded
        } else {
            workoutTitles = ["Emilie's Core Workout"]
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

    var body: some View {
        VStack {
            Text(workoutTitle)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 20)
                .frame(maxWidth: .infinity)

            // Entry row
            HStack {
                TextField("Exercise", text: $firstInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 140)

                Button(action: { isReps.toggle() }) {
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

            // List of exercises
            List {
                ForEach($items) { $item in
                    HStack(spacing: 12) {
                        TextField("Exercise", text: $item.firstInfo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 140)

                        Spacer()

                        if item.unit == "Secs" {
                            Button(action: { toggleTimer(for: item) }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "clock")
                                    if activeTimer == item.id { Text("\(remainingTime)s") }
                                }
                            }
                            .foregroundColor(.blue)
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
            .toolbar { EditButton() }
            .scrollContentBackground(.hidden)
            .background(Color("PrimaryBackground"))
            .onChange(of: items) { _, _ in saveItems() }
        }
        .background(Color("SecondaryBackground"))
        .onAppear { loadItems() }
        .onDisappear { saveItems() }
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
            // No local writes here
        }
    }

    private func loadItems() {
        // Always load default workout from bundle
        if let bundleURL = Bundle.main.url(forResource: workoutTitle, withExtension: "json"),
           let bundleData = try? Data(contentsOf: bundleURL),
           let decoded = try? JSONDecoder().decode([ListItem].self, from: bundleData) {
            items = decoded
        }
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
                remainingTime -= 1
                if remainingTime <= 0 {
                    AudioServicesPlaySystemSound(1021)
                    timer?.invalidate()
                    activeTimer = nil
                }
            }
        }
    }
}

// MARK: - Keyboard dismiss helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
