library infinite_wall;

use ::vector::*;
use std::u128::*;
use ::I128::*;
use ::physics::*;

pub struct InfiniteWall {
    start_point: Vector,
    end_point: Vector,
    normal: Vector
}

impl InfiniteWall {
    fn init(self, start_point: Vector, end_point: Vector, is_left_side: bool) -> Self {
        
        let diff = end_point - start_point;

        assert(!(diff.x == I128::zero() && diff.y == I128::zero()));

        let mut normal = Vector::from(diff.y.flip(), diff.x);
        normal = normal / normal.normalize();

        if !is_left_side { normal = normal.times(I128::from_neg(U128::from((0,1)))) }
        
        Self {
            start_point,
            end_point,
            normal
        }
    }

    fn calc_time_of_impact(self, position: Vector, velocity: Vector, radius: U128) -> U128 {

        let i128_zero = I128::from(0);
        let headway = velocity.dot(self.normal).flip();
        if headway < i128_zero || headway == i128_zero {
            return U128::max();
        }

        let dist = (position - self.start_point).dot(self.normal);
        let gap = dist - I128::from_u128(radius);

        (gap / headway).abs()
    }

    fn collide(self, position: Vector, velocity: Vector, radius: U128) -> Vector {
        let headway = velocity.dot(self.normal).flip();
        assert(headway > I128::from(0));
        
        let i128_two = I128::from(2);
        let bla = self.normal.times(i128_two * headway);

        velocity + bla
    }
}