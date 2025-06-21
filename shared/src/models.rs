use serde::{Deserialize, Serialize};
use uuid::Uuid;
use log::{info, debug, warn};

/// Represents an exercise in the weightlifting app
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Exercise {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub muscle_groups: Vec<String>,
    pub equipment_needed: Option<String>,
    pub difficulty_level: u8, // 1-10 scale
}

impl Exercise {
    /// Create a new exercise with automatic ID generation
    ///
    /// # Arguments
    /// * `name` - Name of the exercise
    /// * `description` - Optional description
    /// * `muscle_groups` - List of muscle groups targeted
    /// * `equipment_needed` - Optional equipment required
    /// * `difficulty_level` - Difficulty from 1-10 (will be clamped)
    pub fn new(
        id: String,
        name: String,
        description: Option<String>,
        muscle_groups: Vec<String>,
        equipment_needed: Option<String>,
        difficulty_level: u8,
    ) -> Self {
        debug!("🏗️ Creating new exercise: {}", name);

        // Clamp difficulty level to valid range (1-10)
        let clamped_difficulty = difficulty_level.clamp(1, 10);
        if clamped_difficulty != difficulty_level {
            warn!("⚠️ Difficulty level {} clamped to {} for exercise '{}'",
                  difficulty_level, clamped_difficulty, name);
        }

        // Validate muscle groups
        if muscle_groups.is_empty() {
            warn!("⚠️ Exercise '{}' created with no muscle groups", name);
        } else {
            debug!("💪 Exercise '{}' targets: {:?}", name, muscle_groups);
        }

        // Log equipment requirements
        if let Some(ref equipment) = equipment_needed {
            debug!("🏋️ Exercise '{}' requires equipment: {}", name, equipment);
        } else {
            debug!("🤸 Exercise '{}' is bodyweight (no equipment)", name);
        }

        let exercise = Self {
            id,
            name: name.clone(),
            description,
            muscle_groups,
            equipment_needed,
            difficulty_level: clamped_difficulty,
        };

        info!("✅ Created exercise: {} (ID: {}, Difficulty: {})",
              exercise.name, exercise.id, exercise.difficulty_level);

        exercise
    }

    /// Create a new exercise with automatic UUID generation
    ///
    /// # Arguments
    /// * `name` - Name of the exercise
    /// * `description` - Optional description
    /// * `muscle_groups` - List of muscle groups targeted
    /// * `equipment_needed` - Optional equipment required
    /// * `difficulty_level` - Difficulty from 1-10 (will be clamped)
    pub fn new_with_uuid(
        name: String,
        description: Option<String>,
        muscle_groups: Vec<String>,
        equipment_needed: Option<String>,
        difficulty_level: u8,
    ) -> Self {
        let id = Uuid::new_v4().to_string();
        debug!("🆔 Generated UUID for exercise '{}': {}", name, id);

        Self::new(id, name, description, muscle_groups, equipment_needed, difficulty_level)
    }

    /// Validate that the exercise has all required fields
    pub fn validate(&self) -> Result<(), String> {
        debug!("🔍 Validating exercise: {}", self.name);

        if self.name.trim().is_empty() {
            let error = "Exercise name cannot be empty".to_string();
            warn!("❌ Validation failed: {}", error);
            return Err(error);
        }

        if self.muscle_groups.is_empty() {
            let error = "Exercise must target at least one muscle group".to_string();
            warn!("❌ Validation failed: {}", error);
            return Err(error);
        }

        if !(1..=10).contains(&self.difficulty_level) {
            let error = format!("Difficulty level must be between 1 and 10, got {}", self.difficulty_level);
            warn!("❌ Validation failed: {}", error);
            return Err(error);
        }

        debug!("✅ Exercise validation passed for: {}", self.name);
        Ok(())
    }

    /// Get a human-readable difficulty description
    pub fn difficulty_description(&self) -> &'static str {
        match self.difficulty_level {
            1..=2 => "Very Easy",
            3..=4 => "Easy",
            5..=6 => "Moderate",
            7..=8 => "Hard",
            9..=10 => "Very Hard",
            _ => "Unknown", // Should never happen due to clamping
        }
    }

    /// Check if this exercise requires equipment
    pub fn requires_equipment(&self) -> bool {
        self.equipment_needed.is_some()
    }

    /// Get the number of muscle groups targeted
    pub fn muscle_group_count(&self) -> usize {
        self.muscle_groups.len()
    }
}