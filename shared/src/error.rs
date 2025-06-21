use thiserror::Error;

/// Custom error types for the weightlifting core library
#[derive(Error, Debug)]
pub enum WeightliftingError {
    /// Database-related errors
    #[error("Database error: {message}")]
    DatabaseError { message: String },

    /// Exercise not found errors
    #[error("Exercise not found with ID: {id}")]
    ExerciseNotFound { id: String },

    /// Invalid input errors
    #[error("Invalid input: {message}")]
    InvalidInput { message: String },
}

impl From<rusqlite::Error> for WeightliftingError {
    fn from(err: rusqlite::Error) -> Self {
        WeightliftingError::DatabaseError {
            message: err.to_string(),
        }
    }
}

impl From<r2d2::Error> for WeightliftingError {
    fn from(err: r2d2::Error) -> Self {
        WeightliftingError::DatabaseError {
            message: err.to_string(),
        }
    }
}