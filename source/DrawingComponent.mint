component DrawingComponent {
  connect Data exposing { size, shapes }
  connect Ui exposing { hoveredPoint, inputMode, newShape }

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
    Data.removeShapeAt(
      `+(document.elementFromPoint(event.clientX, event.clientY)?.getAttribute('data-index') ?? -1)`)
  }

  fun onPointerDown (event : Html.Event) : Promise(Never, Void) {
    if (event.button == 0) {
      sequence {
        `#{event.currentTarget}.setPointerCapture(#{event}.event.pointerId)`

        if (inputMode == InputMode::Eraser) {
          eraseShapeByClientPoint(event.clientX, event.clientY)
        } else {
          Ui.startCreatingShape(svgPointFromEvent(event))
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
          Ui.moveCreatingShapeEndPoint(p)
        } else {
          Promise.never()
        }

        Ui.hoverPoint(p)
      }
    }
  }

  fun onPointerUp (event : Html.Event) : Promise(Never, Void) {
    if (`#{event.currentTarget}.hasPointerCapture(#{event}.event.pointerId)`) {
      Ui.completeCreatingShapeEndPoint()
    } else {
      Promise.never()
    }
  }

  fun render : Html {
    <svg::svg
      viewBox="0 0 #{size} #{size}"
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      onPointerLeave={Ui.leave}
      style="touch-action: none">

      <GridComponent size={size}/>

      <g
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none">

        <{ Array.mapWithIndex(Shape.render, shapes) }>

        <g stroke="hsl(208, 100%, 50%)">
          case (newShape) {
            Maybe::Just shape => Shape.render(shape, -1)
            Maybe::Nothing => Html.empty()
          }
        </g>

      </g>

      if (inputMode != InputMode::Eraser) {
        <GridHighlightComponent
          size={size}
          point={hoveredPoint}/>
      }

    </svg>
  }
}
