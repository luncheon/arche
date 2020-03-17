component Main {
  style main {
    display: block;
    width: calc(100vmin - 80px);
    height: 100vh;
    max-width: 480px;
    margin: auto;
  }

  style drawing {
    width: calc(100vmin - 80px);
    height: calc(100vmin - 80px);
    max-width: 480px;
    max-height: 480px;
    background: white;
    box-shadow: 8px 8px 16px rgba(0,0,0,.1), -8px -8px 16px rgba(255,255,255,.5);
  }

  fun render : Html {
    <main::main>
      <SelectInputModeComponent/>

      <div::drawing>
        <DrawingComponent/>
      </div>
    </main>
  }
}

component SelectInputModeComponent {
  connect Ui exposing { inputMode }

  style radio (active : Bool) {
    margin: 12px 8px;
    padding: 8px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    border-radius: 8px;
    border: 1px solid hsl(208, 60%, 90%);
    transition: background .3s ease-out;

    if (active) {
      background: hsl(208, 100%, 84%);
    } else {
      background: white;
    }

    > input {
      display: none;
    }

    > svg {
      width: 24px;
      height: 24px;
      fill: none;
      stroke: currentColor;
      stroke-width: 2;
      stroke-linecap: round;
      stroke-linejoin: round;

      if (!active) {
        opacity: .3;
      }
    }
  }

  fun onChange (event : Html.Event) : Promise(Never, Void) {
    if (`#{event.target}.checked`) {
      Ui.setInputMode(
        InputMode.fromString(Dom.getValue(event.target)))
    } else {
      Promise.never()
    }
  }

  fun render : Html {
    <div onChange={onChange}>
      <label::radio(inputMode == InputMode::Line)
        title="Line"
        data-ripplet="color: hsla(208, 100%, 84%, .4)">

        <input
          type="radio"
          name="input-mode"
          value="line"
          checked={inputMode == InputMode::Line}/>

        <svg viewBox="0 0 24 24">
          <line
            x1="4"
            y1="20"
            x2="20"
            y2="4"/>
        </svg>

      </label>

      <label::radio(inputMode == InputMode::Arc)
        title="Arc"
        data-ripplet="color: hsla(208, 100%, 84%, .4)">

        <input
          type="radio"
          name="input-mode"
          value="arc"
          checked={inputMode == InputMode::Arc}/>

        <svg viewBox="0 0 24 24">
          <path d="M6 22A5 5 0 0 1 22 6"/>
        </svg>

      </label>

      <label::radio(inputMode == InputMode::Eraser)
        title="Eraser"
        data-ripplet="color: hsla(208, 100%, 84%, .4)">

        <input
          type="radio"
          name="input-mode"
          value="eraser"
          checked={inputMode == InputMode::Eraser}/>

        <svg viewBox="0 0 1000 1000">
          <path
            stroke-width="40"
            d="M535.6,783.4l14.1,14.1l381.8-381.8L612.2,96.3L230.3,478.2l14.1,14.1L131.3,605.4c-31.2,31.2-31.2,81.9,0,113.1L312.7,900 H760v-40H459L535.6,783.4z M612.2,152.9L875,415.7L549.7,741L286.9,478.2L612.2,152.9z M402.4,860h-73.1L159.6,690.3 c-15.6-15.6-15.6-41,0-56.6l113.1-113.1l234.6,234.6L402.4,860z"/>
        </svg>

      </label>
    </div>
  }
}
