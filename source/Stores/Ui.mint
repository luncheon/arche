enum InputMode {
  Line
  Semicircle
  Eraser
}

module InputMode {
  fun fromString (s : String) : InputMode {
    case (s) {
      "Semicircle" => InputMode::Semicircle
      "Eraser" => InputMode::Eraser
      => InputMode::Line
    }
  }

  fun toString (inputMode : InputMode) : String {
    case (inputMode) {
      InputMode::Line => "Line"
      InputMode::Semicircle => "Semicircle"
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
