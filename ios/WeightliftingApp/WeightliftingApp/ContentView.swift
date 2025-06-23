//
//  ContentView.swift
//  WeightliftingApp
//
//  Created by Ross Harrison on 6/21/25.
//

import SwiftUI
import os.log

struct ContentView: View {
    @State private var exercises: [Exercise] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var repository: ExerciseRepository?
    @State private var logMessages: [String] = []

    // Create a logger for this view
    private let logger = Logger(subsystem: "com.example.WeightliftingApp", category: "ContentView")

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🏋️ Weightlifting Core Demo")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("This app demonstrates the Rust core library working through FFI bindings.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let error = errorMessage {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }

                        HStack(spacing: 12) {
                            Button("Initialize Repository & Add Sample Exercises") {
                                initializeAndAddExercises()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button("Load All Exercises") {
                                loadExercises()
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .disabled(repository == nil)
                        }

                        // Log Messages Section
                        if !logMessages.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📋 Activity Log")
                                    .font(.headline)
                                    .padding(.top)

                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 4) {
                                        ForEach(Array(logMessages.enumerated()), id: \.offset) { index, message in
                                            Text(message)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                                .frame(maxHeight: 120)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }

                        List(exercises, id: \.id) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                        .frame(minHeight: 200)
                    }
                }
            }
            .padding()
            .navigationTitle("Weightlifting App")
            .onAppear {
                setupLogging()
            }
        }
    }

    private func setupLogging() {
        logger.info("🚀 Setting up Rust library logging")
        logMessage("🚀 iOS app started, initializing Rust library...")

        // Initialize Rust logging
        initializeLogging()
        logMessage("✅ Rust library logging initialized")
    }

    private func logMessage(_ message: String) {
        let timestamp = DateFormatter.timeFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] \(message)"

        DispatchQueue.main.async {
            logMessages.append(logEntry)
            // Keep only last 20 messages
            if logMessages.count > 20 {
                logMessages.removeFirst()
            }
        }

        logger.info("\(message)")
    }

    private func initializeAndAddExercises() {
        isLoading = true
        errorMessage = nil
        logMessage("🏗️ Starting repository initialization...")

        do {
            // Create in-memory repository
            logMessage("🧠 Creating in-memory repository...")
            repository = try createInMemoryRepository()
            logMessage("✅ Repository created successfully")

            // Create sample exercises
            logMessage("📝 Creating sample exercises...")
            let sampleExercises = [
                Exercise(
                    id: UUID().uuidString,
                    name: "Push-ups",
                    description: "Classic bodyweight exercise for chest and triceps",
                    muscleGroups: ["Chest", "Triceps", "Shoulders"],
                    equipmentNeeded: nil,
                    difficultyLevel: 3
                ),
                Exercise(
                    id: UUID().uuidString,
                    name: "Squats",
                    description: "Fundamental lower body compound movement",
                    muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"],
                    equipmentNeeded: nil,
                    difficultyLevel: 4
                ),
                Exercise(
                    id: UUID().uuidString,
                    name: "Deadlift",
                    description: "King of all exercises - full body compound movement",
                    muscleGroups: ["Hamstrings", "Glutes", "Back", "Traps"],
                    equipmentNeeded: "Barbell",
                    difficultyLevel: 9
                )
            ]

            // Add exercises to repository
            logMessage("💾 Adding \(sampleExercises.count) exercises to repository...")
            for (index, exercise) in sampleExercises.enumerated() {
                logMessage("  ➕ Adding exercise \(index + 1): \(exercise.name)")
                try repository?.addExercise(exercise: exercise)
            }

            logMessage("✅ All sample exercises added successfully")

            // Load exercises to display
            loadExercises()

        } catch {
            let errorMsg = "Failed to initialize: \(error.localizedDescription)"
            errorMessage = errorMsg
            logMessage("❌ \(errorMsg)")
        }

        isLoading = false
    }

    private func loadExercises() {
        guard let repo = repository else {
            logMessage("⚠️ No repository available for loading exercises")
            return
        }

        logMessage("📚 Loading all exercises from repository...")

        do {
            exercises = try repo.getAllExercises()
            logMessage("✅ Loaded \(exercises.count) exercises successfully")

            // Log details about each exercise
            for exercise in exercises {
                logMessage("  📋 Exercise: \(exercise.name) (Difficulty: \(exercise.difficultyLevel)/10)")
            }
        } catch {
            let errorMsg = "Failed to load exercises: \(error.localizedDescription)"
            errorMessage = errorMsg
            logMessage("❌ \(errorMsg)")
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Text("Difficulty: \(exercise.difficultyLevel)/10")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            if let description = exercise.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Muscle Groups: \(exercise.muscleGroups.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.blue)

            if let equipment = exercise.equipmentNeeded {
                Text("Equipment: \(equipment)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    private var difficultyColor: Color {
        switch exercise.difficultyLevel {
        case 1...3:
            return .green
        case 4...6:
            return .orange
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}

#Preview {
    ContentView()
}
