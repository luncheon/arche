store Data {
  state size : Number = 24
  state shapes : Array(Shape) = []

  fun appendShape (shape : Shape) : Promise(Never, Void) {
    next { shapes = Array.push(shape, shapes) }
  }

  fun removeShapeAt (index : Number) : Promise(Never, Void) {
    next { shapes = Array.deleteAt(index, shapes) }
  }
}

enum Shape {
  Line(Line)
  Arc(Arc)
}

record Point {
  x : Number,
  y : Number
}

record Line {
  p1 : Point,
  p2 : Point
}

record Arc {
  p1 : Point,
  p2 : Point,
  r : Number,
  large : Number
}

module Shape {
  fun render (shape : Shape, index : Number) : Html {
    case (shape) {
      Shape::Line line =>
        <line
          data-index="#{index}"
          x1="#{line.p1.x}"
          y1="#{line.p1.y}"
          x2="#{line.p2.x}"
          y2="#{line.p2.y}"/>

      Shape::Arc arc =>
        <path
          data-index="#{index}"
          d="M#{arc.p1.x} #{arc.p1.y}A#{arc.r} #{arc.r} 0 #{arc.large} 1 #{arc.p2.x} #{arc.p2.y}"/>
    }
  }
}
