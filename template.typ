#import "@preview/polylux:0.4.0"
#import "@preview/fontawesome:0.6.0"

#let title-slide(title: none, subtitle: none) = polylux.slide[
  #set align(horizon)
  #show heading.where(level: 1): set text(size: 1.5em)
  #set par(spacing: 1cm)

  #v(3em)
  #text(size: 2.1em, weight: "bold", title)
  
  #text(size: 1.2em, subtitle)

  #set align(bottom)
  #text(size: 0.7em, [
    Maximilian Schmidt, Rasmus Mecklenburg, Konrad Nölle
  ])

  #text(size: 1.4em, {
    fontawesome.fa-creative-commons()
    h(0.2em)
    fontawesome.fa-creative-commons-by()
  })
]

#let slide-body(title: none, body) = {
  show: pad.with(2cm)

  // place(
  //   bottom + right,
  //   dx: 1cm, 
  //   dy: 1cm, 
  //   polylux.toolbox.slide-number
  // )
  
  if title != none {
    grid(
      rows: (auto, 1fr),
      columns: 1fr,
      row-gutter: 1em,
      heading(level: 2, title),
      align(horizon, body)
    )
  } else {
    align(horizon, body)
  }
}

#let image-slide(title: none, image, body) = polylux.slide[
  #set page(margin: 0pt)

  #grid(
    columns: (1fr, auto),
    slide-body(title: title, body),
    image
  )
]

#let slide(title: none, body) = polylux.slide[
  #set page(margin: 0pt)
  #slide-body(title: title, body)
]