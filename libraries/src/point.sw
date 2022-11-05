library point;

dep I128;

use I128::*;

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