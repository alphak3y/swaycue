contract;

use billiard_libs::infinite_wall::*;
use billiard_libs::vector::*;
use billiard_libs::I128::*;
use billiard_libs::physics::*;
use core::num::*;
use std::{
    u128::*,
    u256::*,
    storage::StorageMap,
};

//only owner should be able to call all functions
abi BilliardTable {
    // core functions
    #[storage(read, write)]
    fn add_obstacle(start: Vector, end: Vector, is_left_side: bool) -> u8;

    // returns idx where the ball is stored
    #[storage(read, write)]
    fn add_ball(pos: Vector, vel: Vector, radius: U128, mass: U128) -> u8;

    #[storage(read, write)]
    fn advance_simulation(end_time: U128) -> (Vec<(u8, u8, U128)>, Vec<(u8, u8, U128)>);
}

// Should be all storage variables
storage { 

    time: U128 = U128::from((0,0)),
    
    ball_count: u8 = 0,
    ball_positions: StorageMap<u8, Vector> = StorageMap {},
    ball_velocities: StorageMap<u8, Vector> = StorageMap {},
    ball_radii: StorageMap<u8, U128> = StorageMap {},
    ball_masses: StorageMap<u8, U128> = StorageMap {},

    time_of_impact_table: StorageMap<u8, Vec<U128>> = StorageMap{},   // lower triangular matrix of next impacts
    time_of_impact_min:  StorageMap<u8, (u8, U128)> = StorageMap {},  // (ball index, time) pairs for the next collision for each ball
    time_of_impact_next: (u8, u8, U128) = (0, 0, U128::from((0,0))),   // ((ball index, obstacle index), time) pair for next collision

    obstacle_count: u8 = 0,
    obstacles: StorageMap<u8, InfiniteWall> = StorageMap {},         // list of all obstacles
    obstacles_time_of_impact: StorageMap<u8, (u8, U128)> = StorageMap {},  // (ball index, time) pairs for each ball
    obstacles_next: (u8, u8, U128) = (0, 0, U128::from((0,0))),                             // (ball index, obstacle) pair of the next obstacle
}

impl BilliardTable for Contract {
    #[storage(read, write)]
    fn add_obstacle(start: Vector, end: Vector, is_left_side: bool) -> u8 {
        let wall: InfiniteWall = InfiniteWall::from(start, end, is_left_side);
        storage.obstacles.insert(storage.obstacle_count, wall);
        storage.obstacle_count += 1;

        storage.obstacle_count - 1
    }

    #[storage(read, write)]
    fn add_ball(pos: Vector, vel: Vector, radius: U128, mass: U128) -> u8 {
        //add to storage
        storage.ball_velocities.insert(storage.ball_count, pos);
        storage.ball_positions.insert(storage.ball_count, vel);
        storage.ball_radii.insert(storage.ball_count, radius);
        storage.ball_masses.insert(storage.ball_count, mass);

        //update ball count 
        storage.ball_count += 1;
        let mut idx: u8 = storage.ball_count - 1;

        //calculate next impact time, init row vector
        let mut incr: u8 = 0;
        let mut row_vector: Vec<U128> = Vec::new();

        //iterate through rows
        while incr < idx {
            let row_generation: U128 = calc_time_of_impact(incr, idx);
            row_vector.push(row_generation);
            incr += 1;
        }

        //push to time of impact table
        storage.time_of_impact_table.insert(idx, row_vector);

        //handling collisions
        if row_vector.get(storage.ball_count - 1).unwrap() > U128::from((0,0)) {
            storage.time_of_impact_min.insert(incr, (idx, row_vector.get(0).unwrap()));
        }

        //if no collisions avoid count to inf
        else {
            assert(storage.obstacle_count > 0);
        }
        
        //reset counter, calculate min toi
        incr = 0;
        let mut next_heap = storage.time_of_impact_min.get(0);
        while incr < storage.ball_count {
            if storage.time_of_impact_min.get(incr).1 < next_heap.1 {
                next_heap = storage.time_of_impact_min.get(incr);
            }
            incr += 1;  
        }

        //push obstacles toi to storage
        storage.obstacles_time_of_impact.insert(idx, next_heap);

        return idx;
        
    }

    #[storage(read, write)]
    fn advance_simulation(end_time: U128) -> (Vec<(u8, u8, U128)>, Vec<(u8, u8, U128)>) {
        let mut ball_collisions: Vec<(u8, u8, U128)> = Vec::new();
        let mut obstacle_collisions: Vec<(u8, u8, U128)> = Vec::new();
        let (toi_ball_index_1, toi_ball_index_2, toi_next_time) = storage.time_of_impact_next;
        let (obstacles_next_ball_index, obstacles_next_obstacle_index, obstacles_next_time) = storage.obstacles_next;
        
        let mut end_time_not_exceeded: bool = toi_next_time < end_time || toi_next_time == end_time || obstacles_next_time < end_time || obstacles_next_time == end_time;

        while end_time_not_exceeded {
            if toi_next_time < obstacles_next_time {
                ball_collisions.insert(ball_collisions.len() - 1, bounce_ballball());
            } else {
                obstacle_collisions.insert(obstacle_collisions.len() - 1, bounce_ballobstacle());
            }
            let (toi_ball_index_1, toi_ball_index_2, toi_next_time) = storage.time_of_impact_next;
            let (obstacles_next_ball_index, obstacles_next_obstacle_index, obstacles_next_time) = storage.obstacles_next;
            end_time_not_exceeded = toi_next_time < end_time || toi_next_time == end_time || obstacles_next_time < end_time || obstacles_next_time == end_time;
        }
        
        _move(end_time);

        (ball_collisions, obstacle_collisions)
    }
}

#[storage(read, write)]
fn calc_time_of_impact(ball_index_1: u8, ball_index_2: u8) -> U128 {
    let position_1 = storage.ball_positions.get(ball_index_1);
    let velocity_1 = storage.ball_velocities.get(ball_index_1);
    let radius_1   = storage.ball_radii.get(ball_index_1);

    let position_2 = storage.ball_positions.get(ball_index_2);
    let velocity_2 = storage.ball_velocities.get(ball_index_2);
    let radius_2   = storage.ball_radii.get(ball_index_2);

    storage.time + time_of_impact(position_1, position_2, velocity_1, velocity_2, radius_1, radius_2)
}

#[storage(read, write)]
fn calc_next_obstacle(ball_index: u8) -> (u8, U128) {
    let position = storage.ball_positions.get(ball_index);
    let velocity = storage.ball_velocities.get(ball_index);
    let radius   = storage.ball_radii.get(ball_index);

    let mut time_min = U128::max();
    let mut obstacle_idx = u8::max();

    let mut idx = 0;
    let obstacle_count = storage.obstacle_count;
    
    while idx < obstacle_count {
        let obstacle = storage.obstacles.get(idx);
        let time = obstacle.calc_time_of_impact_wall(position, velocity, radius);
        if time < time_min {
            time_min = time;
            obstacle_idx = idx;
        }
        idx += 1;
    }

    (obstacle_idx, storage.time + time_min)
}

#[storage(read, write)]
fn collide_balls(ball_index_1: u8, ball_index_2: u8) {
    let position_1 = storage.ball_positions.get(ball_index_1);
    let mut velocity_1 = storage.ball_velocities.get(ball_index_1);
    let mut mass_1   = storage.ball_masses.get(ball_index_1);

    let position_2 = storage.ball_positions.get(ball_index_2);
    let mut velocity_2 = storage.ball_velocities.get(ball_index_2);
    let mut mass_2   = storage.ball_masses.get(ball_index_2);

    if mass_1 == U128::max() {
        mass_1 = U128::from((0,1));
        mass_2 = U128::from((0,0));
    } else if mass_2 == U128::max() {
        mass_1 = U128::from((0,0));
        mass_2 = U128::from((0,1));
    }

    let (velocity_1, velocity_2) = elastic_collision(
        position_1,
        position_2,
        velocity_1,
        velocity_2,
        mass_1,
        mass_2
    );
    
    storage.ball_velocities.insert(ball_index_1, velocity_1);
    storage.ball_velocities.insert(ball_index_2, velocity_2);
}

#[storage(read, write)]
fn collide_obstacle(ball_index: u8, obstacle_index: u8) {
    let position = storage.ball_positions.get(ball_index);
    let velocity = storage.ball_velocities.get(ball_index);
    let radius   = storage.ball_radii.get(ball_index);

    let obstacle = storage.obstacles.get(obstacle_index);

    let new_velocity = obstacle.collide(position, velocity, radius);
    storage.ball_velocities.insert(ball_index, new_velocity);
}

#[storage(read, write)]
fn bounce_ballball() -> (u8, u8, U128) {
    let (ball_index_1, ball_index_2, time) = storage.time_of_impact_next;

    assert(ball_index_1 < ball_index_2);

    //need to impl eq
    //assert(storage.time_of_impact_min.get(ball_index_2) == (time, ball_index_1));

    _move(time);
    collide_balls(ball_index_1, ball_index_2);

    // update toi vector for both balls
    let mut row_vector = storage.time_of_impact_table.get(ball_index_1);
    row_vector.insert(ball_index_2, U128::max());
    storage.time_of_impact_table.insert(ball_index_1, row_vector);

    let mut idx = 0;
    let ball_count = storage.ball_count;

    while idx < (ball_index_1 + 1) {
        // update toi_table[ball_index_1][idx]
        let mut row_vector_1 = storage.time_of_impact_table.get(ball_index_1);
        row_vector_1.insert(idx, calc_time_of_impact(ball_index_1, idx));
        storage.time_of_impact_table.insert(ball_index_1, row_vector_1);

        // update toi_table[ball_index_2][idx]
        let mut row_vector_2 = storage.time_of_impact_table.get(ball_index_2);
        row_vector_2.insert(idx, calc_time_of_impact(ball_index_2, idx));
        storage.time_of_impact_table.insert(ball_index_2, row_vector_2);

        // increment counter
        idx += 1;
    }
    while idx < (ball_index_2 + 1) {
        // update toi_table[idx][ball_index_1]
        let mut row_vector_1 = storage.time_of_impact_table.get(idx);
        row_vector_1.insert(ball_index_1, calc_time_of_impact(idx, ball_index_1));
        storage.time_of_impact_table.insert(idx, row_vector_1);

        // update toi_table[ball_index_2][idx]
        let mut row_vector_2 = storage.time_of_impact_table.get(ball_index_2);
        row_vector_2.insert(idx, calc_time_of_impact(ball_index_2, idx));
        storage.time_of_impact_table.insert(ball_index_2, row_vector_2);

        // increment counter
        idx += 1;
    }
    while idx < ball_count {
        // update toi_table[idx][ball_index_1]
        let mut row_vector_1 = storage.time_of_impact_table.get(idx);
        row_vector_1.insert(ball_index_1, calc_time_of_impact(idx, ball_index_1));
        storage.time_of_impact_table.insert(idx, row_vector_1);

        // update toi_table[idx][ball_index_2]
        let mut row_vector_2 = storage.time_of_impact_table.get(idx);
        row_vector_2.insert(ball_index_2, calc_time_of_impact(idx, ball_index_2));
        storage.time_of_impact_table.insert(idx, row_vector_2);

        // increment counter
        idx += 1;
    }

    //storage.time_of_impact_next = min_time

    storage.obstacles_time_of_impact.insert(ball_index_1, calc_next_obstacle(ball_index_1));
    storage.obstacles_time_of_impact.insert(ball_index_2, calc_next_obstacle(ball_index_2));
    
    //storage.obstacles_next = min_time

    (ball_index_1, ball_index_2, time) 
}

#[storage(read, write)]
fn bounce_ballobstacle() -> (u8, u8, U128) {
    let (ball_index, obstacle_index, time) = storage.obstacles_next;

    _move(time);
    collide_obstacle(ball_index, obstacle_index);

    let mut idx = 0;
    let ball_count = storage.ball_count;

    while idx < (ball_index + 1) {
        // update toi_table[ball_index][idx]
        let mut row_vector_1 = storage.time_of_impact_table.get(ball_index);
        row_vector_1.insert(idx, calc_time_of_impact(ball_index, idx));
        storage.time_of_impact_table.insert(ball_index, row_vector_1);

        // increment counter
        idx += 1;
    }

    while idx < (ball_count) {
        // update toi_table[idx][ball_index]
        let mut row_vector_1 = storage.time_of_impact_table.get(idx);
        row_vector_1.insert(ball_index, calc_time_of_impact(idx, ball_index));
        storage.time_of_impact_table.insert(idx, row_vector_1);

        // increment counter
        idx += 1;
    }

    (ball_index, obstacle_index, time)
    
}

#[storage(read, write)]
fn _move(time: U128) {
    assert(time > storage.time);
    let time_delta = time - storage.time;
    
    let mut idx = 0;
    let ball_count = storage.ball_count;

    while idx < ball_count {
        let mut ball_position = storage.ball_positions.get(idx);
        ball_position = ball_position + storage.ball_velocities.get(idx).times(I128::from_u128(time_delta));
        storage.ball_positions.insert(idx, ball_position);
    }

    storage.time = time;
}