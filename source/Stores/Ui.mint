enum InputMode {
  Line
  Arc
  Eraser
}

module InputMode {
  fun fromString (s : String) : InputMode {
    case (s) {
      "Arc" => InputMode::Arc
      "Eraser" => InputMode::Eraser
      => InputMode::Line
    }
  }

  fun toString (inputMode : InputMode) : String {
    case (inputMode) {
      InputMode::Line => "Line"
      InputMode::Arc => "Arc"
      InputMode::Eraser => "Eraser"
    }
  }
}

store Stores.Ui {
  state inputMode : InputMode = InputMode::Line

  fun setInputMode (mode : InputMode) : Promise(Never, Void) {
    next { inputMode = mode }
  }
}
