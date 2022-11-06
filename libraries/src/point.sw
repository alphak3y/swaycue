library point;

use ::I128::*;

pub struct Point {
    x_position: I128,
    y_position: I128,
}

pub trait From {
    /// Function for creating I24 from u32
    fn from(x_position: I128, y_position: I128) -> Self;
}

impl Point {
    /// Helper function to get a signed number from with an underlying
    pub fn from(x_position: I128, y_position: I128) -> Self {
        Self { 
            x_position,
            y_position,
         }
    }
}

impl core::ops::Subtract for Point {
    /// Subtract a I128 from a I128. Panics of overflow.
    fn subtract(self, other: Self) -> Self {
        Self {
            x_position: self.x_position - other.x_position,
            y_position: self.y_position - other.y_position
        }
    }
}