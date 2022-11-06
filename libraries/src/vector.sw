library vector;

use ::I128::*;

pub struct Vector {
    x: I128,
    y: I128,
}

pub trait From {
    /// Function for creating I24 from u32
    fn from(x: I128, y: I128) -> Self;
}

impl Vector {
    /// Helper function to get a signed number from with an underlying
    pub fn from(x: I128, y: I128) -> Self {
        Self { 
            x,
            y,
         }
    }

    // take the dot product of the two vectors
    pub fn dot(self, other: Vector) -> I128 {
        self.x * other.x +
        self.y * other.y
    }
    pub fn times(self, value: I128) -> Self {
        Self {
            x: self.x * value,
            y: self.y * value
        }
    }
}

impl core::ops::Add for Vector {
    /// Add a I128 to a I128.
    fn add(self, other: Self) -> Self {
        Self {
            x: self.x + other.x,
            y: self.y + other.y
        }
    }
}

impl core::ops::Subtract for Vector {
    /// Subtract a I128 from a I128.
    fn subtract(self, other: Self) -> Self {
        Self {
            x: self.x - other.x,
            y: self.y - other.y
        }
    }
}