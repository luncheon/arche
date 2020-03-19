store Stores.Shapes {
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
