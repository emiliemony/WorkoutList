# WorkoutList

**WorkoutList** is a lightweight iOS app that lets you create multiple custom workout lists, each with editable exercises, rep/time tracking, and a simple countdown timer for time-based sets.

| Feature | Details |
|---------|---------|
| **Multiple workout lists** | Create, rename, delete lists on the Home screen |
| **Per-list persistence**   | Each workout list saves locally as its own JSON file |
| **Inline editing**         | Edit exercise names and reps/secs in place |
| **Timer support**          | Tap the clock icon to start / stop a countdown with a chime |
| **Dark-mode friendly**     | Custom `PrimaryBackground` / `SecondaryBackground` colors |

## Requirements

| Requirement            | Version |
|------------------------|---------|
| Xcode                  | 15 or newer |
| iOS Deployment Target  | 16.0+ |
| Swift                  | 5.9 |

## Getting Started

1. **Clone the repo**

   ```bash
   git clone https://github.com/<your-username>/WorkoutList.git
   cd WorkoutList
2. **Open WorkoutList.xcodeproj**
3. **Run on the iOS Simulator**
   In Xcode’s device selector (top bar), choose a simulator
4. **Install on a physical iPhone**
   - Connect your iPhone to your computer via a cable
   - In the device selector, choose your iPhone
   - Press ⌘ R
   - The first time, iOS will ask to trust the developer certificate
