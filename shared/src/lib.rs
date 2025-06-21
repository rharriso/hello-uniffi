// Main library file for weightlifting core
// This exposes the public API and sets up UniFFI bindings

pub mod models;
pub mod repository;
pub mod error;

use models::Exercise;
use repository::ExerciseRepository;
use error::WeightliftingError;
use log::{info, debug, warn};
use std::sync::{Arc, Once};

// UniFFI setup
uniffi::include_scaffolding!("weightlifting_core");

static LOGGER_INIT: Once = Once::new();

/// Initialize logging for the library
/// This should be called once before using the library
pub fn initialize_logging() {
    LOGGER_INIT.call_once(|| {
        env_logger::Builder::from_default_env()
            .filter_level(log::LevelFilter::Debug)
            .format_timestamp_secs()
            .format_module_path(false)
            .init();
        info!("🏋️ Weightlifting Core library logging initialized");
    });
}

/// Create an ExerciseRepository with a SQLite database at the specified path
pub fn create_exercise_repository(db_path: String) -> Result<Arc<ExerciseRepository>, WeightliftingError> {
    initialize_logging();
    info!("📂 Creating file-based exercise repository at: {}", db_path);

    match ExerciseRepository::new(&db_path) {
        Ok(repo) => {
            info!("✅ Successfully created file-based repository");
            Ok(repo)
        }
        Err(e) => {
            warn!("❌ Failed to create file-based repository: {}", e);
            Err(e)
        }
    }
}

/// Create an in-memory ExerciseRepository for testing
pub fn create_in_memory_repository() -> Result<Arc<ExerciseRepository>, WeightliftingError> {
    initialize_logging();
    info!("🧠 Creating in-memory exercise repository");

    match ExerciseRepository::new(":memory:") {
        Ok(repo) => {
            info!("✅ Successfully created in-memory repository");
            Ok(repo)
        }
        Err(e) => {
            warn!("❌ Failed to create in-memory repository: {}", e);
            Err(e)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::NamedTempFile;

    #[test]
    fn test_exercise_creation() {
        initialize_logging();
        debug!("🧪 Running test_exercise_creation");

        let exercise = Exercise::new(
            "test-exercise".to_string(),
            "Push-up".to_string(),
            Some("Basic bodyweight exercise".to_string()),
            vec!["Chest".to_string(), "Triceps".to_string()],
            None,
            5,
        );

        assert_eq!(exercise.id, "test-exercise");
        assert_eq!(exercise.name, "Push-up");
        assert_eq!(exercise.muscle_groups, vec!["Chest", "Triceps"]);
        assert_eq!(exercise.difficulty_level, 5);

        debug!("✅ test_exercise_creation passed");
    }

    #[test]
    fn test_in_memory_repository_crud() {
        initialize_logging();
        debug!("🧪 Running test_in_memory_repository_crud");

        let repo = create_in_memory_repository().expect("Failed to create repository");

        // Test adding an exercise
        let exercise = Exercise::new(
            "test-123".to_string(),
            "Squat".to_string(),
            Some("Leg exercise".to_string()),
            vec!["Quadriceps".to_string(), "Glutes".to_string()],
            Some("Barbell".to_string()),
            6,
        );

        repo.add_exercise(exercise.clone()).expect("Failed to add exercise");

        // Test retrieving the exercise
        let retrieved = repo.get_exercise("test-123".to_string()).expect("Failed to get exercise");
        assert_eq!(retrieved.name, "Squat");
        assert_eq!(retrieved.difficulty_level, 6);

        // Test getting all exercises
        let all_exercises = repo.get_all_exercises().expect("Failed to get all exercises");
        assert_eq!(all_exercises.len(), 1);

        debug!("✅ test_in_memory_repository_crud passed");
    }

    #[test]
    fn test_file_based_repository() {
        initialize_logging();
        debug!("🧪 Running test_file_based_repository");

        let temp_file = NamedTempFile::new().expect("Failed to create temp file");
        let db_path = temp_file.path().to_str().unwrap().to_string();

        let repo = create_exercise_repository(db_path.clone()).expect("Failed to create repository");

        // Test adding and retrieving an exercise
        let exercise = Exercise::new(
            "file-test".to_string(),
            "Deadlift".to_string(),
            Some("Full body compound movement".to_string()),
            vec!["Hamstrings".to_string(), "Glutes".to_string(), "Back".to_string()],
            Some("Barbell".to_string()),
            9,
        );

        repo.add_exercise(exercise.clone()).expect("Failed to add exercise");
        let retrieved = repo.get_exercise("file-test".to_string()).expect("Failed to get exercise");
        assert_eq!(retrieved.name, "Deadlift");

        debug!("✅ test_file_based_repository passed");
    }
}