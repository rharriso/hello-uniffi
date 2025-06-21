use crate::models::Exercise;
use crate::error::WeightliftingError;
use r2d2::Pool;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::{params, Connection};
use serde_json;
use std::sync::Arc;
use log::{info, debug, warn, error};

/// Exercise repository that manages SQLite database operations
/// Uses connection pooling for thread safety and performance
pub struct ExerciseRepository {
    pool: Arc<Pool<SqliteConnectionManager>>,
}

impl ExerciseRepository {
    /// Add a new exercise to the repository
    pub fn add_exercise(&self, exercise: Exercise) -> Result<(), WeightliftingError> {
        info!("➕ Adding exercise: {} (ID: {})", exercise.name, exercise.id);
        debug!("📝 Exercise details: {:?}", exercise);

        let conn = self.pool.get().map_err(|e| {
            error!("❌ Failed to get connection for add_exercise: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to get database connection: {}", e),
            }
        })?;

        let muscle_groups_json = serde_json::to_string(&exercise.muscle_groups)
            .map_err(|e| {
                error!("❌ Failed to serialize muscle groups: {}", e);
                WeightliftingError::DatabaseError {
                    message: format!("Failed to serialize muscle groups: {}", e),
                }
            })?;

        debug!("💾 Inserting into database with muscle_groups: {}", muscle_groups_json);

        conn.execute(
            "INSERT INTO exercises (id, name, description, muscle_groups, equipment_needed, difficulty_level)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
            params![
                exercise.id,
                exercise.name,
                exercise.description,
                muscle_groups_json,
                exercise.equipment_needed,
                exercise.difficulty_level as i32
            ],
        ).map_err(|e| {
            error!("❌ Failed to insert exercise '{}': {}", exercise.name, e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to insert exercise: {}", e),
            }
        })?;

        info!("✅ Successfully added exercise: {}", exercise.name);
        Ok(())
    }

    /// Get an exercise by ID
    pub fn get_exercise(&self, id: String) -> Result<Exercise, WeightliftingError> {
        info!("🔍 Looking up exercise with ID: {}", id);

        let conn = self.pool.get().map_err(|e| {
            error!("❌ Failed to get connection for get_exercise: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to get database connection: {}", e),
            }
        })?;

        debug!("📊 Executing SELECT query for ID: {}", id);

        let mut stmt = conn.prepare(
            "SELECT id, name, description, muscle_groups, equipment_needed, difficulty_level
             FROM exercises WHERE id = ?1"
        ).map_err(|e| {
            error!("❌ Failed to prepare SELECT statement: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to prepare statement: {}", e),
            }
        })?;

        let exercise = stmt.query_row(params![id], |row| {
            let muscle_groups_json: String = row.get(3)?;
            let muscle_groups: Vec<String> = serde_json::from_str(&muscle_groups_json)
                .map_err(|_e| rusqlite::Error::InvalidColumnType(3, "muscle_groups".to_string(), rusqlite::types::Type::Text))?;

            debug!("📋 Found exercise: {}", row.get::<_, String>(1)?);

            Ok(Exercise {
                id: row.get(0)?,
                name: row.get(1)?,
                description: row.get(2)?,
                muscle_groups,
                equipment_needed: row.get(4)?,
                difficulty_level: row.get::<_, i32>(5)? as u8,
            })
        }).map_err(|e| {
            warn!("❌ Exercise not found with ID '{}': {}", id, e);
            WeightliftingError::ExerciseNotFound {
                id: id.to_string(),
            }
        })?;

        info!("✅ Successfully retrieved exercise: {}", exercise.name);
        Ok(exercise)
    }

    /// Get all exercises, sorted by name
    pub fn get_all_exercises(&self) -> Result<Vec<Exercise>, WeightliftingError> {
        info!("📚 Retrieving all exercises from database");

        let conn = self.pool.get().map_err(|e| {
            error!("❌ Failed to get connection for get_all_exercises: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to get database connection: {}", e),
            }
        })?;

        debug!("📊 Executing SELECT query for all exercises");

        let mut stmt = conn.prepare(
            "SELECT id, name, description, muscle_groups, equipment_needed, difficulty_level
             FROM exercises ORDER BY name"
        ).map_err(|e| {
            error!("❌ Failed to prepare SELECT ALL statement: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to prepare statement: {}", e),
            }
        })?;

        let exercise_iter = stmt.query_map([], |row| {
            let muscle_groups_json: String = row.get(3)?;
            let muscle_groups: Vec<String> = serde_json::from_str(&muscle_groups_json)
                .map_err(|_e| rusqlite::Error::InvalidColumnType(3, "muscle_groups".to_string(), rusqlite::types::Type::Text))?;

            Ok(Exercise {
                id: row.get(0)?,
                name: row.get(1)?,
                description: row.get(2)?,
                muscle_groups,
                equipment_needed: row.get(4)?,
                difficulty_level: row.get::<_, i32>(5)? as u8,
            })
        }).map_err(|e| {
            error!("❌ Failed to query all exercises: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to query exercises: {}", e),
            }
        })?;

        let mut exercises = Vec::new();
        for exercise_result in exercise_iter {
            match exercise_result {
                Ok(exercise) => {
                    debug!("📋 Loaded exercise: {}", exercise.name);
                    exercises.push(exercise);
                }
                Err(e) => {
                    error!("❌ Failed to parse exercise row: {}", e);
                    return Err(WeightliftingError::DatabaseError {
                        message: format!("Failed to parse exercise: {}", e),
                    });
                }
            }
        }

        info!("✅ Successfully retrieved {} exercises", exercises.len());
        Ok(exercises)
    }

    /// Delete an exercise by ID
    /// Returns true if an exercise was deleted, false if not found
    pub fn delete_exercise(&self, id: String) -> Result<bool, WeightliftingError> {
        info!("🗑️ Deleting exercise with ID: {}", id);

        let conn = self.pool.get().map_err(|e| {
            error!("❌ Failed to get connection for delete_exercise: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to get database connection: {}", e),
            }
        })?;

        debug!("📊 Executing DELETE query for ID: {}", id);

        let rows_affected = conn.execute(
            "DELETE FROM exercises WHERE id = ?1",
            params![id],
        ).map_err(|e| {
            error!("❌ Failed to delete exercise '{}': {}", id, e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to delete exercise: {}", e),
            }
        })?;

        let deleted = rows_affected > 0;
        if deleted {
            info!("✅ Successfully deleted exercise with ID: {}", id);
        } else {
            warn!("⚠️ No exercise found to delete with ID: {}", id);
        }

        Ok(deleted)
    }

    /// Create a new repository with SQLite backend
    /// Pass ":memory:" for in-memory database, or file path for persistent storage
    pub fn new(db_path: &str) -> Result<Arc<Self>, WeightliftingError> {
        info!("🔧 Initializing ExerciseRepository with database: {}", db_path);

        let manager = SqliteConnectionManager::file(db_path);
        let pool = Pool::new(manager)
            .map_err(|e| {
                error!("❌ Failed to create connection pool: {}", e);
                WeightliftingError::DatabaseError {
                    message: format!("Failed to create connection pool: {}", e),
                }
            })?;

        debug!("📊 Connection pool created successfully");

        // Initialize database schema
        let conn = pool.get().map_err(|e| {
            error!("❌ Failed to get connection from pool: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to get connection from pool: {}", e),
            }
        })?;

        Self::create_table(&conn)?;
        info!("✅ ExerciseRepository initialized successfully");

        Ok(Arc::new(Self { pool: Arc::new(pool) }))
    }

    /// Create the exercises table if it doesn't exist
    fn create_table(conn: &Connection) -> Result<(), WeightliftingError> {
        info!("🏗️ Creating exercises table if not exists");

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
        ).map_err(|e| {
            error!("❌ Failed to create exercises table: {}", e);
            WeightliftingError::DatabaseError {
                message: format!("Failed to create table: {}", e),
            }
        })?;

        debug!("✅ Exercises table ready");
        Ok(())
    }
}