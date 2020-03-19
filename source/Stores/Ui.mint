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

store Stores.Ui {
  state inputMode : InputMode = InputMode::Line

  fun setInputMode (mode : InputMode) : Promise(Never, Void) {
    next { inputMode = mode }
  }
}
