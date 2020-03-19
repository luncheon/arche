store Stores.Shapes {
  state shapes : Array(Shape) = []
  state size : Number = 24
  state strokeWidth : Number = 2

  get path : String {
    for (shape of shapes) {
      case (shape) {
        Shape::Line line => "M#{line.p1.x} #{line.p1.y}L#{line.p2.x} #{line.p2.y}"
        Shape::Arc arc => "M#{arc.p1.x} #{arc.p1.y}A#{arc.r} #{arc.r} 0 #{arc.large} 1 #{arc.p2.x} #{arc.p2.y}"
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
