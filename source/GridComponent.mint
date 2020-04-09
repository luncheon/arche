component GridComponent {
  property size : Number

  style grid-point (x : Number, y : Number) {
    if (x % 2 == 0 && y % 2 == 0) {
      fill: hsla(0, 0%, 50%, .6);
    } else {
      fill: hsla(0, 0%, 50%, .2);
    }
  }

  fun render {
    <g>
      for (y of Array.range(1, size - 1)) {
        <>
          for (x of Array.range(1, size - 1)) {
            <circle::grid-point(x, y)
              cx="#{x}"
              cy="#{y}"
              r=".125"/>
          }
        </>
      }
    </g>
  }
}
