contract;

use core::num::*;
use std::{
    u128::*,
    u256::*,
    storage::StorageMap,
};

pub struct Obstacle {
    start_point: Point,
    end_point: Point,
}

pub struct Point {
    x_position: U128,
    y_position: U128,
}

pub trait From {
    /// Function for creating I24 from u32
    fn from(x_position: U128, y_position: U128) -> Self;
}

impl Point {
    /// Helper function to get a signed number from with an underlying
    pub fn from(x_position: U128, y_position: U128) -> Self {
        Self { 
            x_position,
            y_position,
         }
    }
}

//only owner should be able to call all functions
abi BilliardTable {
    // Core functions
    #[storage(read, write)]
    fn init(obstacle_x_positions: u64, obstacle_y_positions: u64) -> (U128, U128);

    // // returns idx where the ball is stored
    // #[storage(read, write)]
    // internal fn add_ball(position: 2dVector, velocity: 2dVector, radius: u32, mass: u32) -> u8;
    // // returns time of impact of the two balls
    // #[storage(read, write)]
    // fn calc_time_of_impact(ball_idx_1: u8, ball_idx_2: u8) -> u64;
    // // returns time-obstacle pair of the next collision
    // #[storage(read, write)]
    // fn calc_next_obstacle(ball_idx: u8) -> (u64, u64);

    // #[storage(read, write)]
    // internal fn collide_balls(ball_idx_1: u8, ball_idx_2: u8);

    // #[storage(read, write)]
    // internal fn collide_obstacle(ball_idx: u8, obstacle: Obstacle);
    // // returns list of collisions (time_of_impact, ball_index_1, ball_index_2)
    // #[storage(read)]
    // pub fn advance_simulation(end_time: u64) -> Collision[];
    // // returns time of impact along with the two ball indices
    // #[storage(read, write)]
    // pub fn advance_to_next_ball_ball_collision() -> (u64, u8, u8);
    // // returns time of impact along with ball index and Obstacle
    // #[storage(read, write)]
    // pub fn advance_to_next_ball_obstacle_collision() -> (u64, u8, Obstacle);
    // // only updates position
    // #[storage(read)]
    // internal fn _move(time: u64) -> (Q64x64, I24);
}

// Should be all storage variables
storage { 

    time: u64 = 0,
    
    // ball_count: u8 = 0,
    // ball_positions: u32 = 10, // implicitly a u24
    // ball_velocities: u32 = 2500,
    // ball_radii:
    // ball_masses:

    // time_of_impact_table //lower triangular matrix of next impacts
    // time_of_impact_min //time-index pairs for the next collision for each ball
    // time_of_impact_next //time-index-index for next collision

    obstacles: StorageMap<u8, Obstacle> = StorageMap {}, // list of all obstacles
    // obstacles_time_of_impact // time-obstacle pairs for each ball
    // obstacle_next //time-index-obstacle pair of the next obstacle
}

impl BilliardTable for Contract {
    #[storage(read, write)]
    fn init(start_x: u64, start_y: u64, end_x: u64, end_y: u64) -> (U128, U128) {
        // let mut index = 0;
        //let point: Point = ~Point::from(obstacle_x_position, obstacle_y_position);
        //storage.obstacles.insert(obstacle_x_position, obstacle_y_position);
        (~U128::from(0, obstacle_x_position), ~U128::from(0, obstacle_y_position))
        // while index < obstacle_x_positions.length {
        // }
    }
}