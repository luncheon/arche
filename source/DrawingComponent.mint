component DrawingComponent {
  connect Stores.Shapes exposing { shapes }
  connect Stores.NewShape exposing { newShape, startCreatingLine, startCreatingArc, moveCreatingShapeEndPoint, completeCreatingShape }
  connect Stores.Ui exposing { inputMode }

  property size : Number = 24

  state hoveredPoint : Maybe(Point) = Maybe::Nothing

  style svg {
    if (inputMode == InputMode::Eraser) {
      cursor: arrow;
    } else {
      cursor: none;
    }
  }

  fun svgPointFromEvent (event : Html.Event) : Point {
    decode `
      ((event) => {
        const clientPoint = event.currentTarget.createSVGPoint()
        clientPoint.x = event.clientX
        clientPoint.y = event.clientY
        const svgPoint = clientPoint.matrixTransform(event.currentTarget.getScreenCTM().inverse())
        svgPoint.x = #{Math.clamp(1, size - 1)}(Math.round(svgPoint.x))
        svgPoint.y = #{Math.clamp(1, size - 1)}(Math.round(svgPoint.y))
        return svgPoint
      })(#{event})
    ` as Point
    |> Result.withDefault({
      x = -1,
      y = -1
    })
  }

  fun eraseShapeByClientPoint (clientX : Number, clientY : Number) : Promise(Never, Void) {
    Stores.Shapes.removeShapeAt(
      `+(document.elementFromPoint(#{clientX}, #{clientY})?.getAttribute('data-index') ?? -1)`)
  }

  fun onPointerDown (event : Html.Event) : Promise(Never, Void) {
    if (event.button == 0) {
      sequence {
        `#{event.currentTarget}.setPointerCapture(#{event}.event.pointerId)`

        case (inputMode) {
          InputMode::Eraser => eraseShapeByClientPoint(event.clientX, event.clientY)
          InputMode::Line => startCreatingLine(svgPointFromEvent(event))
          InputMode::Arc => startCreatingArc(svgPointFromEvent(event))
        }
      }
    } else {
      Promise.never()
    }
  }

  fun onPointerMove (event : Html.Event) : Promise(Never, Void) {
    if (inputMode == InputMode::Eraser) {
      if (`#{event.currentTarget}.hasPointerCapture(#{event}.event.pointerId)`) {
        eraseShapeByClientPoint(event.clientX, event.clientY)
      } else {
        Promise.never()
      }
    } else {
      sequence {
        p =
          svgPointFromEvent(event)

        if (`#{event.currentTarget}.hasPointerCapture(#{event}.event.pointerId)`) {
          moveCreatingShapeEndPoint(p)
        } else {
          Promise.never()
        }

        next { hoveredPoint = Maybe::Just(p) }
      }
    }
  }

  fun onPointerUp (event : Html.Event) : Promise(Never, Void) {
    if (`#{event.currentTarget}.hasPointerCapture(#{event}.event.pointerId)`) {
      completeCreatingShape()
    } else {
      Promise.never()
    }
  }

  fun onPointerLeave (event : Html.Event) : Promise(Never, Void) {
    next { hoveredPoint = Maybe::Nothing }
  }

  fun render : Html {
    <svg::svg
      viewBox="0 0 #{size} #{size}"
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      onPointerLeave={onPointerLeave}
      style="touch-action: none">

      <GridComponent size={size}/>

      <g
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none">

        <{
          shapes
          |> Array.mapWithIndex(
            (shape : Shape, index : Number) : Html {
              <ShapeComponent
                shape={shape}
                index={index}/>
            })
        }>

        case (newShape) {
          Maybe::Just shape =>
            <g stroke="hsl(208, 100%, 50%)">
              <ShapeComponent shape={shape}/>
            </g>

          Maybe::Nothing => Html.empty()
        }

      </g>

      if (inputMode != InputMode::Eraser) {
        <GridHighlightComponent
          size={size}
          point={hoveredPoint}/>
      }

    </svg>
  }
}

component ShapeComponent {
  property shape : Shape = Shape::Line({
    p1 =
      {
        x = -1,
        y = -1
      },
    p2 =
      {
        x = -1,
        y = -1
      }
  })

  property index : Number = -1

  fun render : Html {
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
