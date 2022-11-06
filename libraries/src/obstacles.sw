/*
Static obstacles on the billiard table.
*/
//@dev everything is scaled up w/ 18 decimal precision
library obstacles;

use std::u128::*;
use ::trig::*;
use ::vector::*;
use ::I128::*;

pub fn linspace(start: U128, stop: U128, num: u32, endpoint: bool) -> Vec<U128> {
    let mut vec: Vec<U128> = Vec::new();

    let num = U128::from((0,num));
    let step_size = (stop - start) / num;
    let mut step = start;

    while step < stop {
        vec.push(step);
        step += step_size;
    }

    if endpoint {
        vec.push(stop);
    }
    
    vec
}

pub fn circle_model(radius: I128, ref mut num_points: u8) -> (Vec<Vector>, Vec<u64>) {
    //default value for num_points
    if num_points == 0 { num_points = 32 }

    // vertices on the circle
    let mut angles = linspace(U128::from((0,0)), two_pi(), num_points, false);
    let mut vertices = Vec::new();
    let mut index = 0;
    while index < num_points {
        let mut angle = angles.get(index).unwrap();
        vertices.push(Vector::from(cos(angle) * radius, sin(angle) * radius));
        num_points += 1;
    }

    // indices for drawing lines
    let mut indices = Vec::new();
    index = 0;
    while index < num_points {
        indices.push(index);
        indices.push(index + 1);
    }
    indices.insert(index - 1, 0);

    (vertices, indices)
}