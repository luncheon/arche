enum InputMode {
  Line
  Semicircle
  QuarterCircle
  Eraser
}

module InputMode {
  fun fromString (s : String) : InputMode {
    case (s) {
      "Semicircle" => InputMode::Semicircle
      "QuarterCircle" => InputMode::QuarterCircle
      "Eraser" => InputMode::Eraser
      => InputMode::Line
    }
  }

  fun toString (inputMode : InputMode) : String {
    case (inputMode) {
      InputMode::Line => "Line"
      InputMode::Semicircle => "Semicircle"
      InputMode::QuarterCircle => "QuarterCircle"
      InputMode::Eraser => "Eraser"
    }
  }
}

store Stores.Ui {
  state inputMode : InputMode = InputMode::Line

  fun setInputMode (mode : InputMode) {
    next { inputMode = mode }
  }
}
