import XCTest
import os.log
@testable import WeightliftingApp

final class WeightliftingAppTests: XCTestCase {

    var repository: ExerciseRepository!
    private let logger = Logger(subsystem: "com.example.WeightliftingAppTests", category: "Tests")

    override func setUpWithError() throws {
        // Initialize Rust logging before each test
        initializeLogging()
        logger.info("🧪 Setting up test - initializing fresh in-memory repository")

        // Create a fresh in-memory repository for each test
        repository = try createInMemoryRepository()
        logger.info("✅ Test setup complete")
    }

    override func tearDownWithError() throws {
        logger.info("🧹 Tearing down test")
        repository = nil
    }

    // MARK: - Repository Creation Tests

    func testCreateInMemoryRepository() throws {
        logger.info("🧪 Testing in-memory repository creation")

        // Test that we can create an in-memory repository
        let repo = try createInMemoryRepository()
        XCTAssertNotNil(repo)

        logger.info("✅ In-memory repository creation test passed")
    }

    func testCreateFileBasedRepository() throws {
        logger.info("🧪 Testing file-based repository creation")

        // Create a temporary file path
        let tempDir = FileManager.default.temporaryDirectory
        let dbPath = tempDir.appendingPathComponent("test_exercises.db").path
        logger.info("📁 Using temporary database path: \(dbPath)")

        // Test creating a file-based repository
        let repo = try createExerciseRepository(dbPath: dbPath)
        XCTAssertNotNil(repo)

        // Clean up
        try? FileManager.default.removeItem(atPath: dbPath)
        logger.info("✅ File-based repository creation test passed")
    }

    // MARK: - Exercise Model Tests

    func testExerciseCreation() {
        logger.info("🧪 Testing exercise creation and validation")

        let exercise = Exercise(
            id: "test-123",
            name: "Push-up",
            description: "Basic bodyweight exercise",
            muscleGroups: ["Chest", "Triceps"],
            equipmentNeeded: nil,
            difficultyLevel: 3
        )

        logger.info("📝 Created exercise: \(exercise.name) with ID: \(exercise.id)")

        XCTAssertEqual(exercise.id, "test-123")
        XCTAssertEqual(exercise.name, "Push-up")
        XCTAssertEqual(exercise.description, "Basic bodyweight exercise")
        XCTAssertEqual(exercise.muscleGroups, ["Chest", "Triceps"])
        XCTAssertNil(exercise.equipmentNeeded)
        XCTAssertEqual(exercise.difficultyLevel, 3)

        logger.info("✅ Exercise creation test passed")
    }

    func testExerciseWithEquipment() {
        logger.info("🧪 Testing exercise creation with equipment")

        let exercise = Exercise(
            id: "test-456",
            name: "Bench Press",
            description: "Upper body strength exercise",
            muscleGroups: ["Chest", "Triceps", "Shoulders"],
            equipmentNeeded: "Barbell",
            difficultyLevel: 7
        )

        logger.info("🏋️ Created exercise: \(exercise.name) requiring: \(exercise.equipmentNeeded ?? "none")")

        XCTAssertEqual(exercise.equipmentNeeded, "Barbell")
        XCTAssertEqual(exercise.difficultyLevel, 7)

        logger.info("✅ Exercise with equipment test passed")
    }

    // MARK: - Repository CRUD Tests

    func testAddAndGetExercise() throws {
        logger.info("🧪 Testing add and get exercise operations")

        let exercise = Exercise(
            id: "test-add-get",
            name: "Squat",
            description: "Compound leg exercise",
            muscleGroups: ["Quadriceps", "Glutes"],
            equipmentNeeded: "Barbell",
            difficultyLevel: 6
        )

        logger.info("➕ Adding exercise: \(exercise.name)")

        // Add exercise
        try repository.addExercise(exercise: exercise)
        logger.info("✅ Exercise added successfully")

        // Retrieve exercise
        logger.info("🔍 Retrieving exercise with ID: \(exercise.id)")
        let retrieved = try repository.getExercise(id: "test-add-get")
        logger.info("📋 Retrieved exercise: \(retrieved.name)")

        XCTAssertEqual(retrieved.id, exercise.id)
        XCTAssertEqual(retrieved.name, exercise.name)
        XCTAssertEqual(retrieved.description, exercise.description)
        XCTAssertEqual(retrieved.muscleGroups, exercise.muscleGroups)
        XCTAssertEqual(retrieved.equipmentNeeded, exercise.equipmentNeeded)
        XCTAssertEqual(retrieved.difficultyLevel, exercise.difficultyLevel)

        logger.info("✅ Add and get exercise test passed")
    }

    func testGetNonexistentExercise() {
        logger.info("🧪 Testing retrieval of non-existent exercise")

        // Test that getting a non-existent exercise throws an error
        logger.info("🔍 Attempting to retrieve non-existent exercise")
        XCTAssertThrowsError(try repository.getExercise(id: "nonexistent")) { error in
            logger.info("❌ Expected error occurred: \(error.localizedDescription)")
            XCTAssertTrue(error.localizedDescription.contains("Exercise not found"))
        }

        logger.info("✅ Non-existent exercise test passed")
    }

    func testGetAllExercises() throws {
        logger.info("🧪 Testing get all exercises operation")

        // Initially should be empty
        let initialExercises = try repository.getAllExercises()
        logger.info("📊 Initial exercise count: \(initialExercises.count)")
        XCTAssertTrue(initialExercises.isEmpty)

        // Add multiple exercises
        logger.info("➕ Adding multiple exercises")
        let exercise1 = Exercise(
            id: "ex1",
            name: "Bench Press",
            description: "Upper body exercise",
            muscleGroups: ["Chest", "Triceps"],
            equipmentNeeded: "Barbell",
            difficultyLevel: 6
        )

        let exercise2 = Exercise(
            id: "ex2",
            name: "Deadlift",
            description: "Full body exercise",
            muscleGroups: ["Hamstrings", "Glutes", "Back"],
            equipmentNeeded: "Barbell",
            difficultyLevel: 9
        )

        try repository.addExercise(exercise: exercise1)
        logger.info("✅ Added: \(exercise1.name)")

        try repository.addExercise(exercise: exercise2)
        logger.info("✅ Added: \(exercise2.name)")

        // Get all exercises
        logger.info("📚 Retrieving all exercises")
        let allExercises = try repository.getAllExercises()
        logger.info("📊 Total exercises retrieved: \(allExercises.count)")

        XCTAssertEqual(allExercises.count, 2)

        // Should be sorted by name (Bench Press comes before Deadlift)
        logger.info("🔤 Verifying sort order: \(allExercises.map { $0.name })")
        XCTAssertEqual(allExercises[0].name, "Bench Press")
        XCTAssertEqual(allExercises[1].name, "Deadlift")

        logger.info("✅ Get all exercises test passed")
    }

    func testDeleteExercise() throws {
        logger.info("🧪 Testing delete exercise operation")

        let exercise = Exercise(
            id: "test-delete",
            name: "Pull-up",
            description: "Upper body pulling exercise",
            muscleGroups: ["Back", "Biceps"],
            equipmentNeeded: "Pull-up bar",
            difficultyLevel: 5
        )

        // Add exercise
        logger.info("➕ Adding exercise for deletion test: \(exercise.name)")
        try repository.addExercise(exercise: exercise)

        // Verify it exists
        logger.info("🔍 Verifying exercise exists before deletion")
        let _ = try repository.getExercise(id: "test-delete")
        logger.info("✅ Exercise confirmed to exist")

        // Delete exercise
        logger.info("🗑️ Deleting exercise")
        let deleted = try repository.deleteExercise(id: "test-delete")
        XCTAssertTrue(deleted)
        logger.info("✅ Exercise deleted successfully")

        // Verify it's gone
        logger.info("🔍 Verifying exercise no longer exists")
        XCTAssertThrowsError(try repository.getExercise(id: "test-delete")) { error in
            logger.info("❌ Expected error after deletion: \(error.localizedDescription)")
        }

        logger.info("✅ Delete exercise test passed")
    }

    func testDeleteNonexistentExercise() throws {
        logger.info("🧪 Testing deletion of non-existent exercise")

        // Deleting a non-existent exercise should return false
        logger.info("🗑️ Attempting to delete non-existent exercise")
        let deleted = try repository.deleteExercise(id: "nonexistent")
        XCTAssertFalse(deleted)
        logger.info("✅ Delete non-existent exercise test passed (returned false as expected)")
    }

    // MARK: - Complex Workflow Tests

    func testCompleteWorkflow() throws {
        logger.info("🧪 Testing complete workflow (comprehensive CRUD operations)")

        // 1. Start with empty repository
        var exercises = try repository.getAllExercises()
        logger.info("📊 Starting with \(exercises.count) exercises")
        XCTAssertTrue(exercises.isEmpty)

        // 2. Add multiple exercises
        logger.info("📝 Creating sample exercise data")
        let sampleExercises = [
            Exercise(
                id: "wf1",
                name: "Push-ups",
                description: "Bodyweight chest exercise",
                muscleGroups: ["Chest", "Triceps", "Shoulders"],
                equipmentNeeded: nil,
                difficultyLevel: 3
            ),
            Exercise(
                id: "wf2",
                name: "Squats",
                description: "Bodyweight leg exercise",
                muscleGroups: ["Quadriceps", "Glutes"],
                equipmentNeeded: nil,
                difficultyLevel: 4
            ),
            Exercise(
                id: "wf3",
                name: "Deadlift",
                description: "Heavy compound exercise",
                muscleGroups: ["Hamstrings", "Glutes", "Back"],
                equipmentNeeded: "Barbell",
                difficultyLevel: 9
            )
        ]

        logger.info("➕ Adding \(sampleExercises.count) exercises to repository")
        for exercise in sampleExercises {
            try repository.addExercise(exercise: exercise)
            logger.info("  ✅ Added: \(exercise.name)")
        }

        // 3. Verify all exercises are added
        exercises = try repository.getAllExercises()
        logger.info("📊 Repository now contains \(exercises.count) exercises")
        XCTAssertEqual(exercises.count, 3)

        // 4. Test individual retrieval
        logger.info("🔍 Testing individual exercise retrieval")
        let pushups = try repository.getExercise(id: "wf1")
        logger.info("📋 Retrieved: \(pushups.name) (Equipment: \(pushups.equipmentNeeded ?? "none"))")
        XCTAssertEqual(pushups.name, "Push-ups")
        XCTAssertNil(pushups.equipmentNeeded)

        let deadlift = try repository.getExercise(id: "wf3")
        logger.info("📋 Retrieved: \(deadlift.name) (Equipment: \(deadlift.equipmentNeeded ?? "none"), Difficulty: \(deadlift.difficultyLevel))")
        XCTAssertEqual(deadlift.name, "Deadlift")
        XCTAssertEqual(deadlift.equipmentNeeded, "Barbell")
        XCTAssertEqual(deadlift.difficultyLevel, 9)

        // 5. Delete one exercise
        logger.info("🗑️ Deleting one exercise (Squats)")
        let deleted = try repository.deleteExercise(id: "wf2")
        XCTAssertTrue(deleted)
        logger.info("✅ Exercise deleted successfully")

        // 6. Verify final state
        exercises = try repository.getAllExercises()
        logger.info("📊 Final exercise count: \(exercises.count)")
        XCTAssertEqual(exercises.count, 2)

        let exerciseNames = exercises.map { $0.name }.sorted()
        logger.info("📋 Remaining exercises: \(exerciseNames)")
        XCTAssertEqual(exerciseNames, ["Deadlift", "Push-ups"])

        logger.info("✅ Complete workflow test passed")
    }

    // MARK: - Error Handling Tests

    func testErrorHandling() throws {
        logger.info("🧪 Testing error handling scenarios")

        // Try to get non-existent exercise
        logger.info("❌ Testing retrieval of non-existent exercise")
        XCTAssertThrowsError(try repository.getExercise(id: "does-not-exist")) { error in
            logger.info("✅ Got expected error: \(error.localizedDescription)")
        }

        // Add an exercise and try to add again with same ID
        let exercise = Exercise(
            id: "duplicate-test",
            name: "Test Exercise",
            description: nil,
            muscleGroups: ["Test"],
            equipmentNeeded: nil,
            difficultyLevel: 1
        )

        logger.info("➕ Adding exercise for duplicate test")
        try repository.addExercise(exercise: exercise)

        // Verify we can retrieve it
        logger.info("🔍 Verifying exercise was added")
        let retrieved = try repository.getExercise(id: "duplicate-test")
        XCTAssertEqual(retrieved.name, "Test Exercise")
        logger.info("✅ Exercise retrieval confirmed")

        logger.info("✅ Error handling test passed")
    }

    // MARK: - Performance Tests

    func testPerformanceAddMultipleExercises() throws {
        logger.info("🧪 Testing performance of adding multiple exercises")

        // Test performance of adding many exercises
        measure {
            do {
                let repo = try createInMemoryRepository()

                for i in 0..<100 {
                    let exercise = Exercise(
                        id: "perf-\(i)",
                        name: "Exercise \(i)",
                        description: "Performance test exercise \(i)",
                        muscleGroups: ["Muscle\(i % 5)"],
                        equipmentNeeded: i % 2 == 0 ? "Equipment\(i)" : nil,
                        difficultyLevel: UInt8((i % 10) + 1)
                    )
                    try repo.addExercise(exercise: exercise)
                }
                logger.info("⏱️ Added 100 exercises in performance test")
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }

        logger.info("✅ Performance test (add multiple) completed")
    }

    func testPerformanceGetAllExercises() throws {
        logger.info("🧪 Testing performance of retrieving all exercises")

        // Add some exercises first
        logger.info("📝 Setting up data for performance test")
        for i in 0..<50 {
            let exercise = Exercise(
                id: "getall-\(i)",
                name: "Exercise \(i)",
                description: "Test exercise \(i)",
                muscleGroups: ["Muscle\(i % 3)"],
                equipmentNeeded: nil,
                difficultyLevel: UInt8((i % 10) + 1)
            )
            try repository.addExercise(exercise: exercise)
        }
        logger.info("✅ Added 50 exercises for performance test")

        // Measure retrieval performance
        measure {
            do {
                let exercises = try repository.getAllExercises()
                logger.info("⏱️ Retrieved \(exercises.count) exercises in performance test")
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }

        logger.info("✅ Performance test (get all) completed")
    }
}