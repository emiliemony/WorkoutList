# WorkoutList

**WorkoutList** is an iOS app that lets you create workout lists, each with editable exercises and rep/time tracking.

| Feature | Details |
|---------|---------|
| Multiple workout lists | Create and delete lists on the Home screen |
| Per-list persistence   | Each workout list saves locally as its own JSON file |
| Inline editing         | Edit exercise names and reps/secs in place |
| Timer support          | Tap the clock icon to start / stop a countdown with a chime |

## Requirements

- iPhone
- Xcode (v15+)

## Getting Started

1. Clone the repo
2. Open WorkoutList.xcodeproj in Xcode
3. Build the app
4. Run on the iOS Simulator
   - In Xcode’s device selector (top bar), choose a simulator
   - Click the build button
5. Install on a physical iPhone
   - Connect your iPhone to your computer via a cable
   - In the device selector, choose your iPhone
   - Click the build button
   - iOS will ask if you trust the developer certificate

## FYI

The app will only work on your iPhone for 7 days before you have to rebuild the app from Xcode. Changes you make to the workouts will be saved.
