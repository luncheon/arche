component DrawingComponent {
  connect Stores.Shapes exposing { shapes, size, strokeWidth }
  connect Stores.NewShape exposing { newShape, startCreatingLine, startCreatingArc, moveCreatingShapeEndPoint, completeCreatingShape }
  connect Stores.Ui exposing { inputMode }

  state hoveredPoint : Maybe(Point) = Maybe::Nothing

  style svg {
    touch-action: none;
    if (inputMode == InputMode::Eraser) {
      cursor: arrow;
    } else {
      cursor: none;
    }
  }

  fun svgPointFromEvent (event : Html.Event) : Point {
    `
      ((event) => {
        const clientPoint = event.currentTarget.createSVGPoint()
        clientPoint.x = event.clientX
        clientPoint.y = event.clientY
        const svgPoint = clientPoint.matrixTransform(event.currentTarget.getScreenCTM().inverse())
        svgPoint.x = #{Math.clamp(1, size - 1)}(Math.round(svgPoint.x))
        svgPoint.y = #{Math.clamp(1, size - 1)}(Math.round(svgPoint.y))
        return svgPoint
      })(#{event})
    `
    |> Result.withDefault(
      {
        x = -1,
        y = -1
      })
  }

  fun eraseShapeByClientPoint (clientX : Number, clientY : Number) {
    Stores.Shapes.removeShapeAt(
      `+(document.elementFromPoint(#{clientX}, #{clientY})?.getAttribute('data-index') ?? -1)`)
  }

  fun onPointerDown (event : Html.Event) {
    if (event.button == 0) {
      sequence {
        `#{event.currentTarget}.setPointerCapture(#{event}.event.pointerId)`

        case (inputMode) {
          InputMode::Eraser => eraseShapeByClientPoint(event.clientX, event.clientY)
          InputMode::Line => startCreatingLine(svgPointFromEvent(event))
          InputMode::Semicircle => startCreatingArc(svgPointFromEvent(event), 180)
          InputMode::QuarterCircle => startCreatingArc(svgPointFromEvent(event), 90)
        }
      }
    } else {
      Promise.never()
    }
  }

  fun onPointerMove (event : Html.Event) {
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

  fun onPointerUp (event : Html.Event) {
    if (`#{event.currentTarget}.hasPointerCapture(#{event}.event.pointerId)`) {
      completeCreatingShape()
    } else {
      Promise.never()
    }
  }

  fun onPointerLeave (event : Html.Event) {
    next { hoveredPoint = Maybe::Nothing }
  }

  fun render {
    <svg::svg
      viewBox="0 0 #{size} #{size}"
      stroke-width="#{strokeWidth}"
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      onPointerLeave={onPointerLeave}>

      <GridComponent size={size}/>

      <g
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none">

        <{
          shapes
          |> Array.mapWithIndex(
            (shape : Shape, index : Number) {
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
  property shape : Shape
  property index = -1

  fun render {
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
          d="#{Stores.Shapes.arcPath(arc)}"/>
    }
  }
}
