record RadioGroupOption {
  title : String,
  value : String,
  content : Html
}

component RadioGroupComponent {
  property name : String
  property options : Array(RadioGroupOption)
  property selectedValue = ""

  property onChange = (value : String) { Promise.never() }

  style label (active : Bool) {
    margin: 12px 8px;
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

    > * {
      if (!active) {
        opacity: .3;
      }
    }
  }

  fun render {
    <div
      onChange={
        (event : Html.Event) {
          if (`#{event.target}.checked`) {
            onChange(Dom.getValue(event.target))
          } else {
            Promise.never()
          }
        }
      }>

      for (option of options) {
        <label::label(option.value == selectedValue)
          title={option.title}
          data-ripplet="color: hsla(208, 100%, 84%, .4)">

          <input
            type="radio"
            name={name}
            value={option.value}
            checked={option.value == selectedValue}/>

          <{ option.content }>

        </label>
      }

    </div>
  }
}
