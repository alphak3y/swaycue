library vector;

use ::I128::*;
use std::u128::*;

pub struct Vector {
    x: I128,
    y: I128,
}

pub trait From {
    /// Function for creating I24 from u32
    fn from(x: I128, y: I128) -> Self;
}

impl Vector {
    pub fn new() -> Self {
        Self {
            x: I128::from(0),
            y: I128::from(0)
        }
    }
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
    pub fn normalize(self) -> Self {
        let normalize_factor = I128::from(1) / I128::from_u128(((self.x * self.x) + (self.y * self.y)).abs().sqrt());
        Self {
            x: self.x * normalize_factor,
            y: self.y * normalize_factor
        }
    }
    pub fn flip(self) -> Self {
        Self {
            x: self.x.flip(),
            y: self.y.flip()
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

impl core::ops::Divide for Vector {
    /// Divide a I128 by a I128.
    fn divide(self, other: Self) -> Self {
        Self {
            x: self.x / other.x,
            y: self.y / other.y
        }
    }
}