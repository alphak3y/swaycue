/*
Static obstacles on the billiard table.
*/
//@dev everything is scaled up w/ 18 decimal precision
// library obstacles;

// pub fn linspace(start: Q64x64, stop: Q64x64, num: u32, endpoint: bool) -> Vec<Q64x64> {
//     let mut vec: Vec<Q64x64> = ~Vec::new();

//     let num = Q64x64::from(num);
//     let step_size = (stop - start) / num;
//     let mut step = start;

//     while step < stop {
//         vec.push(step);
//         step += step_size;
//     }

//     if endpoint {
//         vec.push(stop);
//     }
    
//     vec
// }

// pub fn circle_model(radius: u64, ref mut num_points: u8){
//     //default value for num_points
//     if num_points == 0 { num_points = 32 }

//     angles = linspace(0, 2*pi(), num_points, false);

//     xy = (cos(angles), sin(angles))
// }