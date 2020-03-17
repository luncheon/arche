enum InputMode {
  Line
  Arc
  Eraser
}

module InputMode {
  fun fromString (s : String) : InputMode {
    case (s) {
      "arc" => InputMode::Arc
      "eraser" => InputMode::Eraser
      => InputMode::Line
    }
  }
}

store Ui {
  state inputMode : InputMode = InputMode::Line
  state newShape : Maybe(Shape) = Maybe::Nothing
  state hoveredPoint : Maybe(Point) = Maybe::Nothing

  fun setInputMode (mode : InputMode) : Promise(Never, Void) {
    next { inputMode = mode }
  }

  fun hoverPoint (p : Point) : Promise(Never, Void) {
    next { hoveredPoint = Maybe::Just(p) }
  }

  fun leave : Promise(Never, Void) {
    next { hoveredPoint = Maybe::Nothing }
  }

  fun startCreatingShape (p : Point) : Promise(Never, Void) {
    next
      {
        newShape =
          case (inputMode) {
            InputMode::Line =>
              Maybe::Just(Shape::Line({
                p1 = p,
                p2 = p
              }))

            InputMode::Arc =>
              Maybe::Just(Shape::Arc({
                p1 = p,
                p2 = p,
                r = 0,
                large = 0
              }))

            InputMode::Eraser => Maybe::Nothing
          }
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

                Shape::Arc arc =>
                  Shape::Arc({ arc |
                    p2 = p,
                    r = distance(arc.p1, p) / 2
                  })
              }
            })
      }
  }

  fun completeCreatingShapeEndPoint : Promise(Never, Void) {
    case (newShape) {
      Maybe::Just shape =>
        sequence {
          Data.appendShape(shape)
          next { newShape = Maybe::Nothing }
        }

      Maybe::Nothing => Promise.never()
    }
  }

  fun cancelCreatingShape : Promise(Never, Void) {
    next { newShape = Maybe::Nothing }
  }
}
