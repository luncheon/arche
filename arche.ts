export type ArcheShape = [number, number, number, number, number, number]
export interface ArcheOptions {
  readonly data?: readonly Readonly<ArcheShape>[]
}

export class Arche {
  maxX = 24
  maxY = 24
  strokeWidth = 1
  data = this.options?.data?.map(shape => [...shape] as ArcheShape) ?? []

  #mode: 'line' | 'arc' | 'erase' = 'line'
  get mode() {
    return this.#mode
  }
  set mode(mode) {
    this.#mode = mode
    this.svg.setAttribute('data-mode', mode)
  }

  svg = this._createSvgElement('svg', 'arche', {
    viewBox: this._viewBox(),
    mode: this.mode,
    strokeWidth: this.strokeWidth,
  })
  grid = this.svg.appendChild(this._createSvgElement('g', 'arche-grid'))
  drawing = this.svg.appendChild(this._createSvgElement('g', 'arche-drawing'))

  private _newShapeData: ArcheShape | undefined
  private _newShapeElement = this.svg.appendChild(this._createSvgElement('path', 'arche-new'))

  constructor(private readonly options?: ArcheOptions) {
    for (let cy = 1; cy <= this.maxY; cy++) {
      for (let cx = 1; cx <= this.maxX; cx++) {
          this.grid.appendChild(this._createSvgElement('circle', '', { cx, cy }))
      }
    }
    this.render()
    this.svg.addEventListener('pointerdown', this._onPointerDown)
    this.svg.addEventListener('pointermove', this._onPointerMove)
    this.svg.addEventListener('pointercancel', this._onPointerCancel)
    this.svg.addEventListener('pointerup', this._onPointerUp)
    this.svg.addEventListener('pointerleave', this._onPointerLeave)
  }

  render() {
    this.drawing.innerHTML = ''
    for (let i = 0; i < this.data.length; i++) {
      this.drawing.appendChild(this._createSvgElement('path', '', { 'data-index': i, d: this._path(this.data[i]) }))
    }
  }

  private _viewBox() {
    const halfStrokeWidth = this.strokeWidth / 2
    return `${halfStrokeWidth} ${halfStrokeWidth} ${this.maxX + halfStrokeWidth} ${this.maxY + halfStrokeWidth}`
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
    return 1 <= p.x && p.x <= this.maxX && 1 <= p.y && p.y <= this.maxY ? p : undefined
  }

  private _onPointerDown = (event: PointerEvent) => {
    if (!event.isPrimary || event.button !== 0) {
      return
    }
    if (this.mode === 'erase') {
      const index = +(event.target as Element).getAttribute('data-index')!
      if (this.data[index]) {
        this.data.splice(index, 1)
        this.render()
      }
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

  private _onPointerMove = (event: PointerEvent) => {
    const p = this._svgPointFromClient(event.clientX, event.clientY)
    if (!p) {
      return
    }
    for (let gridPoint = this.grid.firstElementChild as SVGCircleElement; gridPoint; gridPoint = gridPoint.nextElementSibling as SVGCircleElement) {
      gridPoint.classList.toggle('arche-grid-point-hover', gridPoint.cx.baseVal.value === p.x && gridPoint.cy.baseVal.value === p.y)
    }
    if (this._newShapeData && this.svg.hasPointerCapture(event.pointerId)) {
      const [x1, y1] = this._newShapeData
      const r = this.mode === 'line' ? 0 : Math.sqrt((x1 - p.x) * (x1 - p.x) + (y1 - p.y) * (y1 - p.y)) / 2
      this._newShapeData = [x1, y1, p.x, p.y, r, 0]
      this._newShapeElement.setAttribute('d', this._path(this._newShapeData))
    }
  }

  private _onPointerCancel = (event: PointerEvent) => {
    if (this.svg.hasPointerCapture(event.pointerId)) {
      this._newShapeData = undefined
      this._newShapeElement.removeAttribute('d')
      this.svg.releasePointerCapture(event.pointerId)
    }
  }

  private _onPointerUp = (event: PointerEvent) => {
    if (this._newShapeData) {
      this.data.push(this._newShapeData)
      this.render()
    }
    this._onPointerCancel(event)
  }

  private _onPointerLeave = () => {
    for (let gridPoint = this.grid.firstElementChild as SVGCircleElement; gridPoint; gridPoint = gridPoint.nextElementSibling as SVGCircleElement) {
      gridPoint.classList.remove('arche-grid-point-hover')
    }
  }
}
