store Stores.Shapes {
  state shapes = []
  state size = 24
  state strokeWidth = 2

  fun arcPath (arc : Arc) : String {
    "M#{arc.p1.x} #{arc.p1.y}A#{r} #{r} 0 #{large} 1 #{arc.p2.x} #{arc.p2.y}"
  } where {
    d =
      Math.sqrt(
        (arc.p1.x - arc.p2.x) * (arc.p1.x - arc.p2.x) + (arc.p1.y - arc.p2.y) * (arc.p1.y - arc.p2.y))

    r =
      d / (2 * `Math.sin(#{arc.degree} * Math.PI / 180 / 2)`)

    large =
      if (arc.degree > 180) {
        1
      } else {
        0
      }
  }

  get path : String {
    for (shape of shapes) {
      case (shape) {
        Shape::Line line => "M#{line.p1.x} #{line.p1.y}L#{line.p2.x} #{line.p2.y}"
        Shape::Arc arc => arcPath(arc)
      }
    }
    |> String.join("")
  }

  get asSvgFileContent : String {
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 #{size} #{size}\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"#{strokeWidth}\" stroke-linecap=\"round\" stroke-linejoin=\"round\">\
<path d=\"#{path}\"/>\
</svg>"
  }

  get asDataUri : String {
    "data:image/svg+xml," + `encodeURIComponent(#{asSvgFileContent})`
  }

  fun appendShape (shape : Shape) {
    next { shapes = Array.push(shape, shapes) }
  }

  fun removeShapeAt (index : Number) {
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
  degree : Number
}
