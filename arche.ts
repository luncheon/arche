export type ArcheShape = [number, number, number, number, number, number]
export interface ArcheOptions {
  readonly data?: readonly Readonly<ArcheShape>[]
}

export class Arche {
  data = this.options?.data?.map(shape => [...shape] as ArcheShape) ?? []

  svg: SVGSVGElement = this._createSvgElement('svg', 'arche', { strokeWidth: 1 })
  grid = this.svg.appendChild(this._createSvgElement('g', 'arche-grid'))
  drawing = this.svg.appendChild(this._createSvgElement('g', 'arche-drawing'))

  private _erasing = false
  private _newShapeData: ArcheShape | undefined
  private _newShapeElement = this.svg.appendChild(this._createSvgElement('path', 'arche-new'))

  private _hoverClass = matchMedia('(hover:hover)') ? 'arche-grid-point-hover' : ''

  get size() {
    return this.svg.viewBox.baseVal.width
  }
  set size(size) {
    this.svg.setAttribute('viewBox', `0 0 ${size} ${size}`)
    for (let cy = 1; cy < size; cy++) {
      const row = this.grid.appendChild(this._createSvgElement('g', 'arche-grid-row'))
      for (let cx = 1; cx < size; cx++) {
          row.appendChild(this._createSvgElement('circle', 'arche-grid-point', { cx, cy }))
      }
    }
  }

  get mode() {
    const mode = this.svg.getAttribute('data-mode')
    return mode === 'line' || mode === 'arc' || mode === 'erase' ? mode : 'line'
  }
  set mode(mode: 'line' | 'arc' | 'erase') {
    this.svg.setAttribute('data-mode', mode)
  }

  constructor(private readonly options?: ArcheOptions) {
    this.size = 24
    this.mode = 'line'
    this.svg.addEventListener('contextmenu', e => e.preventDefault())
    this.svg.addEventListener('pointerover', this._onPointerOver)
    this.svg.addEventListener('pointerdown', this._onPointerDown)
    this.svg.addEventListener('pointermove', this._onPointerMove)
    this.svg.addEventListener('pointercancel', this._onPointerCancel)
    this.svg.addEventListener('pointerup', this._onPointerUp)
    this.svg.addEventListener('pointerleave', this._onPointerLeave)
    this.render()
  }

  render() {
    this.drawing.innerHTML = ''
    for (let i = 0; i < this.data.length; i++) {
      this.drawing.appendChild(this._createSvgElement('path', '', { 'data-index': i, d: this._path(this.data[i]) }))
    }
  }

  private _createSvgElement<K extends keyof SVGElementTagNameMap>(qualifiedName: K, className: string, attributes?: Record<string, string | number>) {
    const element = document.createElementNS('http://www.w3.org/2000/svg', qualifiedName)
    className && element.setAttribute('class', className)
    if (attributes) {
      for (const a of Object.entries(attributes)) {
        element.setAttribute(a[0], a[1] as string)
      }
    }
    return element
  }

  private _path([x1, y1, x2, y2, r, large]: Readonly<ArcheShape>) {
    return `M${x1} ${y1} A${r} ${r} 0 ${large} 1 ${x2} ${y2}`
  }

  private _svgPointFromClient(clientX: number, clientY: number) {
    let p = this.svg.createSVGPoint()
    p.x = clientX
    p.y = clientY
    p = p.matrixTransform(this.svg.getScreenCTM()!.inverse())
    p.x = Math.round(p.x)
    p.y = Math.round(p.y)
    return 0 < p.x && p.x < this.size && 0 < p.y && p.y < this.size ? p : undefined
  }

  private _onPointerDown = (event: PointerEvent) => {
    if (event.button !== 0) {
      return
    }
    if (this.mode === 'erase') {
      this._erasing = true
      this._onPointerOver(event)
      return
    }
    const p = this._svgPointFromClient(event.clientX, event.clientY)
    if (!p) {
      return
    }
    this._newShapeData = [p.x, p.y, p.x, p.y, 0, 0]
    this._newShapeElement.setAttribute('d', this._path(this._newShapeData))
    this.svg.setPointerCapture(event.pointerId)
  }

  private _onPointerOver = (event: PointerEvent) => {
    if (this._erasing) {
      const index = +((event.target as Element).getAttribute('data-index') ?? -1)
      if (this.data[index]) {
        this.data.splice(index, 1)
        this.render()
      }
    }
  }

  private _onPointerMove = (event: PointerEvent) => {
    if (this.mode === 'erase') {
      return
    }
    const p = this._svgPointFromClient(event.clientX, event.clientY)
    if (!p) {
      return
    }
    const { grid, _hoverClass: hoverClass } = this
    if (hoverClass) {
      grid.getElementsByClassName(hoverClass)[0]?.classList.remove(hoverClass)
      grid.querySelector(`[cx="${p.x}"][cy="${p.y}"]`)?.classList.add(hoverClass)
    }
    if (this._newShapeData && this.svg.hasPointerCapture(event.pointerId)) {
      const [x1, y1] = this._newShapeData
      const r = this.mode === 'line' ? 0 : Math.sqrt((x1 - p.x) * (x1 - p.x) + (y1 - p.y) * (y1 - p.y)) / 2
      this._newShapeData = [x1, y1, p.x, p.y, r, 0]
      this._newShapeElement.setAttribute('d', this._path(this._newShapeData))
    }
  }

  private _onPointerCancel = () => {
    this._erasing = false
    this._newShapeData = undefined
    this._newShapeElement.removeAttribute('d')
  }

  private _onPointerUp = () => {
    if (this._newShapeData) {
      this.data.push(this._newShapeData)
      this.render()
    }
    this._onPointerCancel()
  }

  private _onPointerLeave = () => {
    const { _hoverClass: hoverClass } = this
    if (hoverClass) {
      this.grid.getElementsByClassName(hoverClass)[0]?.classList.remove(hoverClass)
    }
  }
}
