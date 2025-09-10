use std::marker::PhantomData;

struct Point2<Frame> {
    x: f32,
    y: f32,
    frame: PhantomData<Frame>,
}

impl<Frame> Point2<Frame> {
    pub fn new(x: f32, y: f32) -> Self {
        Self {
            x,
            y,
            frame: PhantomData,
        }
    }
}

struct World;
struct Robot;

fn walk_to_point(target: Point2<Robot>) {
    // ...
}

fn main() {
    let ball = Point2::<World>::new(3.0, 2.0);
    walk_to_point(ball);
}
