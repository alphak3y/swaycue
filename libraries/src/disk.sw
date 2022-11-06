library disk;

use ::vector::*;
use std::u128::*;
use ::I128::*;
use ::physics::*;

pub struct Disk {
    center: Vector,
    radius: U128,
}

impl Disk {
    fn init(self, center: Vector, radius: U128) -> Self {
        Self {
            center,
            radius
        }
    }

    fn calc_time_of_impact(self, position: Vector, velocity: Vector, radius: U128) -> U128 {
        let mut vector = Vector::new();
        time_of_impact(self.center, position, vector, velocity, self.radius, radius)
    }

    fn collide(self, position: Vector, ref mut velocity: Vector, radius: U128) -> Vector {
        let i128_one = I128::from(1);
        let mut vector = Vector::new();
        let (velocity_1, velocity_2) = elastic_collision(self.center, position, vector, velocity, U128::from((0,1)), U128::from((0,0)));
        velocity_2
    }
}