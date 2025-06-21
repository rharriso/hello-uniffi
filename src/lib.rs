pub mod models;
pub mod repository;
pub mod error;

use std::sync::Arc;
pub use models::Exercise;
pub use repository::ExerciseRepository;
pub use error::WeightliftingError;

// UniFFI will generate bindings for these types and functions
uniffi::include_scaffolding!("weightlifting_core");

/// Create a new ExerciseRepository with SQLite backend
pub fn create_exercise_repository(db_path: Option<String>) -> Result<Arc<ExerciseRepository>, WeightliftingError> {
    ExerciseRepository::new(db_path.as_deref())
}

/// Convenience function to create an in-memory repository for testing
pub fn create_in_memory_repository() -> Result<Arc<ExerciseRepository>, WeightliftingError> {
    ExerciseRepository::new(Some(":memory:"))
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::NamedTempFile;

    #[test]
    fn test_exercise_creation() {
        let exercise = Exercise::new(
            "Push-up".to_string(),
            Some("Basic bodyweight exercise".to_string()),
            vec!["Chest".to_string(), "Triceps".to_string()],
            None,
            3,
        );

        assert_eq!(exercise.name, "Push-up");
        assert_eq!(exercise.description, Some("Basic bodyweight exercise".to_string()));
        assert_eq!(exercise.muscle_groups, vec!["Chest", "Triceps"]);
        assert_eq!(exercise.equipment_needed, None);
        assert_eq!(exercise.difficulty_level, 3);
        assert!(!exercise.id.is_empty());
    }

    #[test]
    fn test_in_memory_repository_crud() {
        let repo = create_in_memory_repository().expect("Failed to create repository");

        // Test adding an exercise
        let exercise = Exercise::with_id(
            "test-123".to_string(),
            "Squat".to_string(),
            Some("Compound leg exercise".to_string()),
            vec!["Quadriceps".to_string(), "Glutes".to_string()],
            Some("Barbell".to_string()),
            7,
        );

        repo.add_exercise(exercise.clone()).expect("Failed to add exercise");

        // Test retrieving the exercise
        let retrieved = repo.get_exercise("test-123".to_string()).expect("Failed to get exercise");
        assert_eq!(retrieved, exercise);

        // Test getting all exercises
        let all_exercises = repo.get_all_exercises().expect("Failed to get all exercises");
        assert_eq!(all_exercises.len(), 1);
        assert_eq!(all_exercises[0], exercise);

        // Test deleting the exercise
        let deleted = repo.delete_exercise("test-123".to_string()).expect("Failed to delete exercise");
        assert!(deleted);

        // Verify it's gone
        let result = repo.get_exercise("test-123".to_string());
        assert!(result.is_err());
    }

    #[test]
    fn test_file_based_repository() {
        let temp_file = NamedTempFile::new().expect("Failed to create temp file");
        let db_path = temp_file.path().to_str().unwrap().to_string();

        let repo = create_exercise_repository(Some(db_path.clone())).expect("Failed to create repository");

        // Add an exercise
        let exercise = Exercise::with_id(
            "ex1".to_string(),
            "Bench Press".to_string(),
            Some("Upper body strength exercise".to_string()),
            vec!["Chest".to_string(), "Triceps".to_string(), "Shoulders".to_string()],
            Some("Barbell".to_string()),
            6,
        );

        repo.add_exercise(exercise.clone()).expect("Failed to add exercise");

        // Test retrieval
        let retrieved = repo.get_exercise("ex1".to_string()).expect("Failed to get exercise");
        assert_eq!(retrieved, exercise);
    }
}