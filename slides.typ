#import "@preview/ansi-render:0.8.0": *
#import "template.typ": *
#import "catppuccin.typ": *
#import polylux: later, uncover, alternatives, one-by-one

#let catppuccin-theme = (
  fg: catppuccin.text,
  bg: catppuccin.crust,
)

#let colorscheme = catppuccin-theme

#set page(fill: colorscheme.bg, paper: "presentation-16-9")
#set text(fill: colorscheme.fg, font: "Hanken Grotesk", size: 8mm)
#set raw(theme: "catppuccin.tmtheme")
#set list(indent: 1em)
#show raw: set text(font: "Fira Code")

// HACK: Append this to code blocks to preserve trailing whitespace
#show "ZWS": sym.zws  

// HACK: Rust syntax highlighting is very broken,
// and it makes "From" a different color than other generics
#show raw.where(lang: "rust"): it => {
  show regex("(From)|(To)|(Frame\b)|(T\b)|(Rotation)|(Inner)"): set text(catppuccin.peach)
  show regex("DIMENSION"): set text(fill: catppuccin.yellow)
  show regex("f32"): set text(fill: catppuccin.lavender)
  show regex(",|<|>|:"): set text(fill: catppuccin.overlay2)
  
  it
}

// Fix list items not hiding the markers properly
#let no-par-spacing(it) = (
  context {
    set par(spacing: par.leading)
    it
  }
)

#show list: no-par-spacing
#show enum: no-par-spacing

#show hide: it => {
  show list.item: list
  show enum.item: enum

  it
}
#let checkbox = text(size: 1.5em, fontawesome.fa-square())
#let check = text(fill: green, size: 2em, fontawesome.fa-check())
  

// HACK: make SVGs follow the color scheme :)
//
// It uses hardcoded catppuccin colors for now,
// because it's not easy to convert a color to a string afaik
#show image: it => {
  if type(it.source) == str and it.source.ends-with(".svg") {
    let svg = read(it.source, encoding: "utf8")
      .replace(regex("(?i)#f{6}"), "#cad3f5") 
      .replace(regex("#(00){3,4}"), "#181926")

    let other-args = it.fields()
    let _ = other-args.remove("source")
    image(bytes(svg), ..other-args)
  } else {
    it
  }
}

#let code-box = box.with(
  stroke: catppuccin.lavender + 0.8pt,
  radius: 1em,
  inset: 1em,
  width: 100%,
  fill: catppuccin.base
)

#let render-compiler-error(path) = {
  let compiler-error = read(path)
  ansi-render(
    theme: catppuccin-terminal-theme,
    font: "Fira Code",
    compiler-error
  )
}

#show "TODO": set text(fill: red)

// Debug mode
//#set grid(stroke: blue)

#title-slide(
  title: [Lost in translation?!],
  subtitle: [Robotics with type-safe coordinate systems]
)

#slide(title: [Who are we?])[
  #grid(
    columns: (1fr, 0.8fr),
    [
      - Team from Hamburg (TUHH)
      - Active in Robot Soccer since 2013
      - Open Source Contribution to software and research papers
    ],
    image("assets/robocup-2024.jpg"),
  )

  #v(0.5em)
  #set align(center)
  First team to seriously *integrate Rust* #box(move(dy: 0.2em, image("assets/rustacean-flat-happy.svg", height: 1em))) in robot control
]

#image-slide(
  title: [What is RoboCup?],
  image("assets/kick_cropped.jpg")
)[
  - International competition
  - autonomous soccer robots
  - Standard Platform League (SPL):\
    -> all teams use identical robots

  #sym.arrow.double Real-time robotics under physical, strategic, and computational constraints
]

#slide(title: [Where do we use Rust?])[
  #image("assets/stack.svg")
]
  
#for i in range(1, 8) {
  slide(title: [Meet Alice and Bob])[
    #align(center + bottom, image("assets/bob-and-alice/0"+str(i)+".svg", height: 90%))
  ]
}

#slide[
  #set align(center)
  
  #text(size: 2em)[Coordinates alone are not enough!]

  We're missing the frame of reference
]

#slide(title: [#strike(stroke: 5pt)[Requirements] Expectations])[
  We need something that:

  #set list(marker: checkbox)
  
  - prevents Alice & Bob bugs
  - allows safe, easy frame conversion
  - checked at compile time
  - is zero cost
  - self-documenting frames
]

#slide(title: [How do we achieve all this?])[
  #set list(marker: sym.arrow.r)

  #v(1cm)
  
  #alternatives(position: top)[][
    ```rust
    struct Point2 {
      x: f32,
      y: f32,
    }
    ```
  ][
    ```rust
    struct Point2 {
      x: f32,
      y: f32,
      frame: Frame,
    }

    enum Frame {
      World,
      Robot,
      // and many more
    }
    ```
  ][
    ```rust
    struct Point2 {
      x: f32,
      y: f32,
      frame: Frame,
    }

    enum Frame {
      World,
      Robot,
      // and many more
    }
    ```

    This is not zero-cost...
  ][
    ```rust
    struct WorldPoint2 {
      x: f32,
      y: f32,
    }
    
    struct RobotPoint2 {
      x: f32,
      y: f32,
    }
    ```
  ][
    ```rust
    struct WorldPoint2 {
      x: f32,
      y: f32,
    }
    
    struct RobotPoint2 {
      x: f32,
      y: f32,
    }

    ```
    
    This does not scale well...
  ][
    ```rust
    struct Point2<Frame> {
      x: f32,
      y: f32,
    }
    ```
  ][
    ```rust
    struct Point2<Frame> {
      x: f32,
      y: f32,
    }
    ```

    And this does not (yet) compile
  ]
]

#slide(title: [Enter Phantom Data])[
  - A zero-sized marker type
  - Carries compile-time information only
  - Adds no runtime cost
  - Used to "phantomly" associate a type parameter with data
]

#slide(title: [The Solution: Make types generic over the frame])[
  #show raw: code-box
  #show raw: set align(left)


  #set align(center)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #uncover(2)[_⚠️ ambiguous_]
    ```rust
    struct Point2 {
      x: f32,
      y: f32,
    }
    ZWS
    ```
  ][
    #uncover(2)[
      _✅ frame-safe_
      ```rust
      struct Point2<Frame> {
        x: f32,
        y: f32,
        frame: PhantomData<Frame>,
      }
      ```
    ]
  ]
]

#slide(title: [Now we can tag points with their reference frame!])[
  #set align(center)
  
  #image("assets/code1.svg")
]

#slide(title: [... piecing it together])[
  #set align(center)
  
  #image("assets/code2.svg")
]

#slide(title: [And this does not compile!])[
  #render-compiler-error("assets/compiler-errors/missing_semicolon.txt")
]

#slide(title: [... piecing it together, take two])[
  #set align(center)
  
  #image("assets/code2.svg")
]

#slide(title: [... piecing it together, take two])[
  #set align(center)
  
  #image("assets/code2-with-semicolon.svg")
]

#slide(title: [And this does not compile!])[
  #render-compiler-error("assets/compiler-errors/point_frame_mismatch.txt")
  #place(
    horizon + right,
    image("assets/rustacean-flat-gesture.svg", height: 5em)
  )
]

#slide(title: [How do we transform a point?])[
  #show raw: code-box
  #show raw: set align(left)
  #set align(center)
  
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #uncover(3)[
      _⚠️ ambiguous_
    ]
    #uncover("2-")[
      ```rust
      struct Isometry2 {
        x: f32,
        y: f32,
        angle: f32,
      }
      
      ZWS
      ```
    ]
  ][
    #uncover(3)[
      _✅ frame-safe_
      ```rust
      struct Isometry2<From, To> {
        x: f32,
        y: f32,
        angle: f32,
        from: PhantomData<From>,
        to: PhantomData<To>,
      }
      ```
    ]
  ]
]

#slide(title: [How do we transform a point?])[
  The magic happens in the `impl`:
  ```rust
  impl<From, To> Mul<Point2<From>> for Isometry2<From, To> {
    type Output = Point2<To>;
  
    fn mul(self, rhs: Point2<From>) -> Self::Output {
      // apply transformation
    }
  }
  ```
]

#slide(title: [Transform Alice's ball])[
  ```rust
  let ball: Point2<World> = ...;
  let world_to_robot: Isometry2<World, Robot> = ...;

  let ball_robot = world_to_robot * ball;
  ```
  #show: later
  ```rust
  fn walk_to_point(target: Point2<Robot>) {
    // ...
  }
  walk_to_point(ball_robot);
  ```

  #place(
    horizon + right,
    dy: 5em,
    dx: -5em,
    image("assets/rustacean-flat-happy.svg", height: 5em),
  )
  #place(
    right+horizon,
    dy: -2em,
    text(size: 6em, emoji.party)
  )
]

#slide(title: [Wrong frames -> compiler error])[
  ```rust
  let ball: Point2<World> = ...;
  let robot_to_world: Isometry2<Robot, World> = ...;

  let ball_in_world = robot_to_world * ball;
  ```
]

#slide(title: [Wrong frames -> compiler error])[
  #render-compiler-error("assets/compiler-errors/cannot_multiply.txt")
]

#slide(title: [Linear Algebra is not only Points])[
  #polylux.one-by-one(
    place(dx: 2em, dy: 1em, [Point]),
    place(dx: 2em, dy: 2.5em, [Vector]),
    place(dx: 2em, dy: 4em, [Plane]),
    place(dx: 2em, dy: 5.5em, text(1em)[Hyperplane]),
    place(dx: 10em, dy: 6em, rotate(0deg, text(1.5em)[Translation])),
    place(dx: 12em, dy: 2em, rotate(220deg, text(1.5em)[Rotation])),
    place(dx: 15em, dy: 10em, scale(x: -100%, rotate(10deg, text(1.5em)[Reflection]))),
    place(dx: 22em, dy: 5em, rotate(3deg, text(3.8em)[Scaling])),
    place(dx: 2em, dy: 10em, rotate(3deg, text(2.8em)[#skew(ax: -12deg)[Shear]])),
    place(dx: 8em, dy: 7em, rotate(-35deg, scale(y: 40%, text(3.8em)[Projection]))),
    place(dx: 3em, dy: 6em, rotate(-39deg, text(1.8em)[Perspective])),
    place(dx: 25em, dy: 11em, rotate(13deg, text(2em)[Affine])),
    place(dx: 3em, dy: 2em, rotate(-11deg, text(4em)[Kinematic Chain])),
  )
]

#slide(title: [Let's search on `crates.io`])[
  #set align(center)
  #v(0.3em)
  #image("assets/cratesio.png", width: 80%)
  
  #v(1em)
  `nalgebra` already has all these basic types
  #v(1em)
  #grid(columns: (1fr, 1fr), rows: (40em))[
    #place(image("assets/github.png", width: 96%))
  ][
    #place(image("assets/nalgebradocu.png", width: 96%))
  ]
]

#slide(title: [Wrapping `nalgebra`])[
  #polylux.alternatives(position: top)[
    ```rust
    ZWS
    struct Framed<Frame, Inner> {
        frame: PhantomData<Frame>,
        pub inner: Inner,
    }
    ```
  ][
    ```rust
    #[repr(transparent)]
    struct Framed<Frame, Inner> {
        frame: PhantomData<Frame>,
        pub inner: Inner,
    }
    ```
  ][
    ```rust
    #[repr(transparent)]
    struct Framed<Frame, Inner> {
        frame: PhantomData<Frame>,
        pub inner: Inner,
    }
  
    type Point2<Frame, T> = Framed<Frame, nalgebra::Point2<T>>;
    type Vector2<Frame, T> = Framed<Frame, nalgebra::Vector2<T>>;
    // and more...
    ```
  ]
  
]

#slide(title: [Using wrapped types is no different])[
  #show raw: code-box
  #show raw: set text(size: 0.9em)
  #show raw: set align(left)

  #set align(center)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    // column-gutter: 0.5em,
    // align: center,
    // stroke: red
  )[
    #uncover(2)[_⚠️ ambiguous_]
    ```rust
    use nalgebra::Point2;

    
    

    fn walk_to_point(
      target: Point2<f32>,
    ) { /**/ }

    fn robot_to_world(
      point: Point2<f32>,
    ) -> Point2<f32> { /**/ }
    ```
  ][
    #uncover(2)[
      _✅ frame-safe_
      ```rust
      use linear_algebra::Point2;
      
      struct World;
      struct Robot;
  
      fn walk_to_point(
        target: Point2<World, f32>
      ) { /**/ }
  
      fn robot_to_world(
        point: Point2<Robot, f32>,
      ) -> Point2<World, f32> { /**/ }
      ```
    ]
  ]
]


#slide(title: [... the same for transforms])[
  #polylux.alternatives(position: top)[
    ```rust
    #[repr(transparent)]
    struct Transform<From, To, Inner> {
        from: PhantomData<From>,
        to: PhantomData<To>,
        pub inner: Inner,
    }
    ```
  ][
    ```rust
    #[repr(transparent)]
    struct Transform<From, To, Inner> {
        from: PhantomData<From>,
        to: PhantomData<To>,
        pub inner: Inner,
    }
  
    type Isometry3<From, To, T> =
      Transform<From, To, nalgebra::Isometry3<T>>;
    // and more...
    ```
  ]

#let item-by-item-map-inactive(start: 1, show-inactive, body) = {
  let is-item(it) = (
    type(it) == content
      and it.func()
        in (
          list.item,
          enum.item,
          terms.item,
        )
  )
  let children = if type(body) == content and body.has("children") {
    body.children
  } else {
    body
  }
  let items = children.filter(is-item)
  for (idx, child) in items.enumerate() {
    if idx == items.len() - 1 {
      uncover((beginning: start + idx), child)
    } else {
      uncover(
        (beginning: start + idx),
        child.func()(alternatives(start: start + idx, repeat-last: true, child.body, show-inactive(child.body))),
      )
    }
  }
}]

#let checkbox-list(start: 2, body) = context {
  let checkbox-width = measure(checkbox).width
  let check-width = measure(check).width
  
  let is-item(it) = (
    type(it) == content
      and it.func() == list.item
  )
  let children = if type(body) == content and body.has("children") {
    body.children
  } else {
    body
  }
  let items = children.filter(is-item)

  set list(marker: checkbox)

  for (idx, child) in items.enumerate() {
    child.func()(
      {
        polylux.uncover(
          (beginning: start + idx),
          place(
            dx: -list.body-indent
              - checkbox-width,
            dy: -0.7em,
            check
          )
        )
        child.body
      }
    )
  }
}

#slide(title: [Defining Frames])[
  `$ head crates/coordinate_systems/src/lib.rs`
  #v(0.3em)
  ```rust
  /// 3D coordinate system centered on the robot.
  ///
  /// Origin: hip of the robot
  /// X axis pointing forward
  /// Y axis pointing left
  struct Robot;
  /// 2D coordinate system centered on the robot.
  ///
  /// Origin: center between feet, projected onto the ground.
  /// X axis pointing forward
  struct Ground;
  ```
]

#slide(title: [Real-World Example])[
  #set text(size: 0.7em)
  #set align(top)
  #set block(spacing: 3mm)

  ```rust
  fn paint_target_feet(
  ```
  #polylux.reveal-code(lines: (0, 1, 3, 6))[
    ```rust
        painter: &TwixPainter<Ground>,
        robot_to_walk: Isometry3<Robot, Walk>,
        robot_to_ground: Isometry3<Robot, Ground>,
        support_sole: Pose3<Walk>,
        end_support_sole: Pose3<Walk>,
        end_swing_sole: Pose3<Walk>,
    ```
  ]
  ```
  ) {
  ```
  #polylux.reveal-code(lines: (2, 5, 7), start: 5)[
    ```rust
        let walk_to_robot = robot_to_walk.inverse();
    
        struct SupportSole;
        let upcoming_walk_to_support_sole =
            end_support_sole.as_transform::<SupportSole>().inverse();
        let target_swing_sole/*: Pose3<Robot> */ =
            support_sole.as_transform() * upcoming_walk_to_support_sole * end_swing_sole;
    
        painter.paint_sole_polygon(
            robot_to_ground * walk_to_robot * target_swing_sole,
        );
    ```
  ]
  ```rust
  }
  ```
]

#slide(title: [Benefits and Conclusion])[
  #checkbox-list[
    - prevents Alice & Bob bugs
    - allows safe, easy frame conversion
    - checked at compile time
    - is zero cost
    - self-documenting frames
  ]
]

#slide[
  #let qr-label(url, label) = link(
    url,
    text(font: "Fira Code", label)
  )
  
  #grid(
    columns: (1fr, 1fr),
    align: center,
    row-gutter: (0.5em, 1.5em, 0.5em),
    // stroke: red,
    image(width: 30%, "assets/qr/hulks.svg"),
    image(width: 30%, "assets/qr/slides.svg"),
    qr-label(
      "https://hulks.de",
      [#fontawesome.fa-globe() hulks.de]
    ),
    qr-label(
      "https://github.com/HULKs/oxidize-2025-lost-in-translation",
      //sublabel: "Made with Typst",
      [#fontawesome.fa-github() Slides]
    ),
    image(width: 30%, "assets/qr/youtube.svg"),
    image(width: 30%, "assets/qr/instagram.svg"),
    qr-label(
      "@hulks_tuhh",
      [#fontawesome.fa-youtube() \@hulks_tuhh]
    ),
    qr-label(
      "@hulks_tuhh",
      [#fontawesome.fa-instagram() hulks_tuhh]
    ),
  )
  // qrencode "https://hulks.de" -t SVG -l H --foreground=ffffff -o assets/qr-hulks.svg --background 00000000 --svg-path -m 0

  #let typst-logo = {
    let svg = read(encoding: "utf8", "assets/typst.svg").replace("currentColor", "#239dad")

    image(height: 1em, bytes(svg))
  }
 
  #place(bottom + center, dy: 1.4cm)[
    *Made with* #box(baseline: 2.5mm, typst-logo) *and* #emoji.heart
  ]
]