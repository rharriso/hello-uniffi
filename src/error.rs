use thiserror::Error;

/// Errors that can occur in the weightlifting core library
#[derive(Error, Debug)]
pub enum WeightliftingError {
    #[error("Database error: {message}")]
    DatabaseError { message: String },

    #[error("Exercise not found with id: {id}")]
    ExerciseNotFound { id: String },

    #[error("Invalid input: {message}")]
    InvalidInput { message: String },

    #[error("Connection pool error: {message}")]
    PoolError { message: String },
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
        WeightliftingError::PoolError {
            message: err.to_string(),
        }
    }
}