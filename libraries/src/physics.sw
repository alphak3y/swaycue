library physics;

dep vector;

use vector::*;
use std::u128::*;
use ::I128::*;

pub fn time_of_impact(position_1: Vector, position_2: Vector, velocity_1: Vector, velocity_2: Vector, radius_1: U128, radius_2: U128) -> U128 {
    
    let radius_1 = I128::from_u128(radius_1);
    let radius_2 = I128::from_u128(radius_2);
    let radius_added_squared = (radius_1 + radius_2) * (radius_1 + radius_2);
    
    let position_diff = position_2 - position_1;
    let velocity_diff = velocity_2 - velocity_1;

    let position_dot_velocity: I128 = position_diff.dot(velocity_diff);
    // balls are moving apart so return infinite (i.e. max u128)
    let position_dot_velocity_ge_zero = position_dot_velocity > I128::zero() || position_dot_velocity == I128::zero();
    if position_dot_velocity_ge_zero { return U128::max() }

    let position_squared = position_diff.dot(position_diff);
    let velocity_squared = velocity_diff.dot(velocity_diff);

    assert(velocity_squared > I128::zero());

    // time of impact is given as the solution of the quadratic equation
    // t^2 + b t + c = 0 with b and c below
    let b = position_dot_velocity / velocity_squared;
    assert(b > I128::zero());
    let c = (position_squared - radius_added_squared) / velocity_squared;

    let discriminant = b * b - c;
    if discriminant < I128::zero() || discriminant == I128::zero() {
        return U128::max()
    }

    // when writing the solution of the quadratic equation use that
    // c = t1 t2 (prevents rounding errors)
    let t1 = b.flip() + I128::from_u128(discriminant.abs().sqrt()); // note: t1 > 0
    assert( t1 > I128::zero());
    let t2 = c / t1;

    let ret = if t1 < t2 { t1 } else { t2 };

    ret.abs()
}

pub fn elastic_collision(position_1: Vector, position_2: Vector, ref mut velocity_1: Vector, ref mut velocity_2: Vector, mass_1: U128, mass_2: U128) -> (Vector, Vector) {
    let mass_1 = I128::from_u128(mass_1);
    let mass_2 = I128::from_u128(mass_2);

    // switch to coordinate system of ball 1
    let position_diff = position_2 - position_1;
    let velocity_diff = velocity_2 - velocity_1;

    let position_dot_velocity: I128 = position_diff.dot(velocity_diff);
    // colliding balls do not move apart
    assert(position_dot_velocity < I128::zero());

    let distance_squared = position_diff.dot(position_diff);

    let bla_x = I128::from(2) * (position_dot_velocity * position_diff.x) / ((mass_1 + mass_2) * distance_squared);
    let bla_y = I128::from(2) * (position_dot_velocity * position_diff.y) / ((mass_1 + mass_2) * distance_squared);
    let bla = Vector::from(bla_x, bla_y);
    velocity_1 += bla.times(mass_2);
    velocity_2 += bla.times(mass_1);

    (velocity_1, velocity_2)

}