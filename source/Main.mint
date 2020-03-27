component Main {
  connect Stores.Shapes exposing { asDataUri }
  connect Stores.Ui exposing { inputMode, setInputMode }

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

  style icon {
    width: 32px;
    height: 32px;
    padding: 8px;
    fill: none;
    stroke: currentColor;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
  }

  style preview-container {
    width: 32px;
    height: 32px;
    padding: 8px;
    margin: 12px 8px;
    background-color: white;
    outline: 1px solid hsl(208, 60%, 90%);
  }

  style preview {
    width: 16px;
    height: 16px;
    display: block;
    outline: 1px dotted hsl(208, 60%, 90%);
  }

  const OPTIONS = [
    {
      value = InputMode.toString(InputMode::Line),
      title = "Line",
      content =
        <svg::icon viewBox="0 0 24 24">
          <line
            x1="4"
            y1="20"
            x2="20"
            y2="4"/>
        </svg>
    },
    {
      value = InputMode.toString(InputMode::Semicircle),
      title = "Semicircle",
      content =
        <svg::icon viewBox="0 0 24 24">
          <path d="M6 22A5 5 0 0 1 22 6"/>
        </svg>
    },
    {
      value = InputMode.toString(InputMode::Eraser),
      title = "Eraser",
      content =
        <svg::icon viewBox="0 0 1000 1000">
          <path
            stroke-width="40"
            d="M535.6,783.4l14.1,14.1l381.8-381.8L612.2,96.3L230.3,478.2l14.1,14.1L131.3,605.4c-31.2,31.2-31.2,81.9,0,113.1L312.7,900 H760v-40H459L535.6,783.4z M612.2,152.9L875,415.7L549.7,741L286.9,478.2L612.2,152.9z M402.4,860h-73.1L159.6,690.3 c-15.6-15.6-15.6-41,0-56.6l113.1-113.1l234.6,234.6L402.4,860z"/>
        </svg>
    }
  ]

  fun render : Html {
    <main::main>
      <div style="display: flex">
        <RadioGroupComponent
          name="input-mode"
          options={OPTIONS}
          selectedValue={InputMode.toString(inputMode)}
          onChange={
            (value : String) : Promise(Never, Void) {
              setInputMode(InputMode.fromString(value))
            }
          }/>

        <div style="flex: auto"/>

        <div::preview-container>
          <img::preview
            tabindex="0"
            alt="Download SVG file from context menu"
            src={asDataUri}/>
        </div>
      </div>

      <div::drawing>
        <DrawingComponent/>
      </div>
    </main>
  }
}
