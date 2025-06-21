use serde::{Deserialize, Serialize};

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
    /// Create a new exercise with a generated UUID
    pub fn new(
        name: String,
        description: Option<String>,
        muscle_groups: Vec<String>,
        equipment_needed: Option<String>,
        difficulty_level: u8,
    ) -> Self {
        Self {
            id: uuid::Uuid::new_v4().to_string(),
            name,
            description,
            muscle_groups,
            equipment_needed,
            difficulty_level: difficulty_level.clamp(1, 10),
        }
    }

    /// Create an exercise with a specific ID (useful for testing)
    pub fn with_id(
        id: String,
        name: String,
        description: Option<String>,
        muscle_groups: Vec<String>,
        equipment_needed: Option<String>,
        difficulty_level: u8,
    ) -> Self {
        Self {
            id,
            name,
            description,
            muscle_groups,
            equipment_needed,
            difficulty_level: difficulty_level.clamp(1, 10),
        }
    }
}