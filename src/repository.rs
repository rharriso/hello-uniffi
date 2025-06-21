use crate::models::Exercise;
use crate::error::WeightliftingError;
use r2d2_sqlite::SqliteConnectionManager;
use r2d2::Pool;
use rusqlite::{params, Row};
use std::sync::Arc;

type ConnectionPool = Pool<SqliteConnectionManager>;

/// Repository for managing exercises with SQLite backend
pub struct ExerciseRepository {
    pool: ConnectionPool,
}

impl ExerciseRepository {
    /// Create a new ExerciseRepository with SQLite backend
    ///
    /// # Arguments
    /// * `db_path` - Optional path to SQLite database file. If None, uses "exercises.db"
    pub fn new(db_path: Option<&str>) -> Result<Arc<Self>, WeightliftingError> {
        let db_path = db_path.unwrap_or("exercises.db");
        let manager = SqliteConnectionManager::file(db_path);
        let pool = Pool::new(manager)?;

        // Initialize the database schema
        let conn = pool.get()?;
        conn.execute(
            "CREATE TABLE IF NOT EXISTS exercises (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                muscle_groups TEXT NOT NULL,
                equipment_needed TEXT,
                difficulty_level INTEGER NOT NULL
            )",
            [],
        )?;

        Ok(Arc::new(Self { pool }))
    }

    /// Add a new exercise to the repository
    pub fn add_exercise(&self, exercise: Exercise) -> Result<(), WeightliftingError> {
        let conn = self.pool.get()?;

        // Serialize muscle_groups as JSON string
        let muscle_groups_json = serde_json::to_string(&exercise.muscle_groups)
            .map_err(|e| WeightliftingError::InvalidInput {
                message: format!("Failed to serialize muscle groups: {}", e)
            })?;

        conn.execute(
            "INSERT INTO exercises (id, name, description, muscle_groups, equipment_needed, difficulty_level)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
            params![
                exercise.id,
                exercise.name,
                exercise.description,
                muscle_groups_json,
                exercise.equipment_needed,
                exercise.difficulty_level
            ],
        )?;

        Ok(())
    }

    /// Get an exercise by its ID
    pub fn get_exercise(&self, id: String) -> Result<Exercise, WeightliftingError> {
        let conn = self.pool.get()?;

        let mut stmt = conn.prepare(
            "SELECT id, name, description, muscle_groups, equipment_needed, difficulty_level
             FROM exercises WHERE id = ?1"
        )?;

        let exercise = stmt.query_row(params![id], |row| {
            self.row_to_exercise(row)
        }).map_err(|e| match e {
            rusqlite::Error::QueryReturnedNoRows => WeightliftingError::ExerciseNotFound { id: id.clone() },
            _ => WeightliftingError::from(e),
        })?;

        Ok(exercise)
    }

    /// Get all exercises from the repository
    pub fn get_all_exercises(&self) -> Result<Vec<Exercise>, WeightliftingError> {
        let conn = self.pool.get()?;

        let mut stmt = conn.prepare(
            "SELECT id, name, description, muscle_groups, equipment_needed, difficulty_level
             FROM exercises ORDER BY name"
        )?;

        let exercises = stmt.query_map([], |row| {
            self.row_to_exercise(row)
        })?
        .collect::<Result<Vec<_>, _>>()?;

        Ok(exercises)
    }

    /// Delete an exercise by its ID
    pub fn delete_exercise(&self, id: String) -> Result<bool, WeightliftingError> {
        let conn = self.pool.get()?;

        let rows_affected = conn.execute(
            "DELETE FROM exercises WHERE id = ?1",
            params![id],
        )?;

        Ok(rows_affected > 0)
    }

    /// Helper function to convert a database row to an Exercise
    fn row_to_exercise(&self, row: &Row) -> Result<Exercise, rusqlite::Error> {
        let muscle_groups_json: String = row.get(3)?;
        let muscle_groups: Vec<String> = serde_json::from_str(&muscle_groups_json)
            .map_err(|e| rusqlite::Error::FromSqlConversionFailure(
                3,
                rusqlite::types::Type::Text,
                Box::new(e),
            ))?;

        Ok(Exercise {
            id: row.get(0)?,
            name: row.get(1)?,
            description: row.get(2)?,
            muscle_groups,
            equipment_needed: row.get(4)?,
            difficulty_level: row.get(5)?,
        })
    }
}