store Stores.NewShape {
  state newShape : Maybe(Shape) = Maybe::Nothing

  fun startCreatingLine (p : Point) : Promise(Never, Void) {
    next
      {
        newShape =
          Maybe::Just(Shape::Line({
            p1 = p,
            p2 = p
          }))
      }
  }

  fun startCreatingArc (p : Point, degree : Number) : Promise(Never, Void) {
    next
      {
        newShape =
          Maybe::Just(Shape::Arc({
            p1 = p,
            p2 = p,
            degree = degree
          }))
      }
  }

  fun distance (p1 : Point, p2 : Point) : Number {
    Math.sqrt(
      (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y))
  }

  fun moveCreatingShapeEndPoint (p : Point) : Promise(Never, Void) {
    next
      {
        newShape =
          newShape
          |> Maybe.map(
            (shape : Shape) : Shape {
              case (shape) {
                Shape::Line line => Shape::Line({ line | p2 = p })
                Shape::Arc arc => Shape::Arc({ arc | p2 = p })
              }
            })
      }
  }

  fun completeCreatingShape : Promise(Never, Void) {
    case (newShape) {
      Maybe::Just shape =>
        sequence {
          Stores.Shapes.appendShape(shape)
          next { newShape = Maybe::Nothing }
        }

      Maybe::Nothing => Promise.never()
    }
  }

  fun cancelCreatingShape : Promise(Never, Void) {
    next { newShape = Maybe::Nothing }
  }
}
