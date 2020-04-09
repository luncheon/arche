component GridHighlightComponent {
  property size : Number
  property point : Maybe(Point) = Maybe::Nothing

  fun render {
    case (point) {
      Maybe::Just p =>
        <g fill="hsl(208, 100%, 84%)">
          for (x of Array.range(1, size - 1)) {
            <circle
              cx="#{x}"
              cy="#{p.y}"
              r=".25"/>
          }

          for (y of Array.range(1, size - 1)) {
            <circle
              cx="#{p.x}"
              cy="#{y}"
              r=".25"/>
          }

          <circle
            cx="#{p.x}"
            cy="#{p.y}"
            r=".5"
            fill="hsl(208, 100%, 60%)"/>
        </g>

      Maybe::Nothing => Html.empty()
    }
  }
}
