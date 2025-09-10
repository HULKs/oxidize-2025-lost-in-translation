use std::{marker::PhantomData, ops::Mul};

struct Point2<Frame> {
    x: f32,
    y: f32,
    frame: PhantomData<Frame>,
}

struct Isometry2<From, To> {
    frame: PhantomData<(From, To)>,
}

impl<From, To> Mul<Point2<From>> for Isometry2<From, To> {
    type Output = Point2<To>;

    fn mul(self, rhs: Point2<From>) -> Self::Output {
        todo!()
    }
}

struct Robot;
struct Field;

fn main() {
    let ball: Point2<Field> = todo!();
    let robot_to_field: Isometry2<Robot, Field> = todo!();

    let ball_in_field = robot_to_field * ball;
}
