library physics;

dep vector;

use vector::*;

fn time_of_impact(position_1: Vector, position_2: Vector, velocity_1: Vector, velocity_2: Vector, radius_1: U128, radius_2: U128) -> U128 {
    let position_diff = position_2 - position_1;
    let velocity_diff = velocity_2 - velocity_1;

    let position_dot_velocity: I128 = position_diff.dot(velocity_diff);
    // balls are moving apart so return infinite (i.e. max u128)
    if position_dot_velocity >= 0 { return U128::max() }

    let position_squared = position_diff.dot(position_diff);

}

fn elastic_collision(position_1: Vector, position_2: Vector, mass_1: U128, position_2: U128, velocity_2: U128, mass_2: U128) {

}