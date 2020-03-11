const clamp = (value, min, max) => Math.max(min, Math.min(max, value));
export class Arche {
    constructor(options) {
        this.options = options;
        this.data = this.options?.data?.map(shape => [...shape]) ?? [];
        this.svg = this._createSvgElement('svg', 'arche', { strokeWidth: 1 });
        this.grid = this.svg.appendChild(this._createSvgElement('g', 'arche-grid'));
        this.drawing = this.svg.appendChild(this._createSvgElement('g', 'arche-drawing'));
        this._erasing = false;
        this._newShapeElement = this.svg.appendChild(this._createSvgElement('path', 'arche-new'));
        this._clearTemporaryState = () => {
            this._erasing = false;
            this._newShapeData = undefined;
            this._newShapeElement.removeAttribute('d');
            this._hover();
        };
        this._onPointerDown = (event) => {
            if (event.button !== 0) {
                return;
            }
            if (this.mode === 'erase') {
                this._erasing = true;
                this._onPointerMove(event);
                return;
            }
            const { x, y } = this._svgPointFromClient(event.clientX, event.clientY);
            this._newShapeData = [x, y, x, y, 0, 0];
            this._newShapeElement.setAttribute('d', this._path(this._newShapeData));
            this.svg.setPointerCapture(event.pointerId);
        };
        this._onPointerMove = (event) => {
            if (this.mode === 'erase') {
                if (this._erasing) {
                    const index = +(document.elementFromPoint(event.clientX, event.clientY)?.getAttribute('data-index') ?? -1);
                    if (this.data[index]) {
                        this.data.splice(index, 1);
                        this.render();
                    }
                }
                return;
            }
            const p = this._svgPointFromClient(event.clientX, event.clientY);
            const { x, y } = p;
            this._hover(p);
            if (this._newShapeData && this.svg.hasPointerCapture(event.pointerId)) {
                const [x1, y1] = this._newShapeData;
                const r = this.mode === 'line' ? 0 : Math.sqrt((x1 - x) * (x1 - x) + (y1 - y) * (y1 - y)) / 2;
                this._newShapeData = [x1, y1, x, y, r, 0];
                this._newShapeElement.setAttribute('d', this._path(this._newShapeData));
            }
        };
        this._onPointerUp = () => {
            if (this._newShapeData) {
                this.data.push(this._newShapeData);
                this.render();
            }
            this._clearTemporaryState();
        };
        this.size = 24;
        this.mode = 'line';
        this.svg.addEventListener('contextmenu', e => e.preventDefault());
        this.svg.addEventListener('pointerdown', this._onPointerDown);
        this.svg.addEventListener('pointermove', this._onPointerMove);
        this.svg.addEventListener('pointerup', this._onPointerUp);
        this.svg.addEventListener('pointercancel', this._clearTemporaryState);
        this.svg.addEventListener('pointerleave', () => this._hover());
        this.render();
    }
    get size() {
        return this.svg.viewBox.baseVal.width;
    }
    set size(size) {
        this.svg.setAttribute('viewBox', `0 0 ${size} ${size}`);
        for (let cy = 1; cy < size; cy++) {
            const row = this.grid.appendChild(this._createSvgElement('g', 'arche-grid-row'));
            for (let cx = 1; cx < size; cx++) {
                row.appendChild(this._createSvgElement('circle', 'arche-grid-point', { cx, cy }));
            }
        }
    }
    get mode() {
        const mode = this.svg.getAttribute('data-mode');
        return mode === 'line' || mode === 'arc' || mode === 'erase' ? mode : 'line';
    }
    set mode(mode) {
        this.svg.setAttribute('data-mode', mode);
        this._clearTemporaryState();
    }
    render() {
        this.drawing.innerHTML = '';
        for (let i = 0; i < this.data.length; i++) {
            this.drawing.appendChild(this._createSvgElement('path', '', { 'data-index': i, d: this._path(this.data[i]) }));
        }
    }
    _createSvgElement(qualifiedName, className, attributes) {
        const element = document.createElementNS('http://www.w3.org/2000/svg', qualifiedName);
        className && element.setAttribute('class', className);
        if (attributes) {
            for (const a of Object.entries(attributes)) {
                element.setAttribute(a[0], a[1]);
            }
        }
        return element;
    }
    _path([x1, y1, x2, y2, r, large]) {
        return `M${x1} ${y1} A${r} ${r} 0 ${large} 1 ${x2} ${y2}`;
    }
    _svgPointFromClient(clientX, clientY) {
        let p = this.svg.createSVGPoint();
        p.x = clientX;
        p.y = clientY;
        p = p.matrixTransform(this.svg.getScreenCTM().inverse());
        const max = this.size - 1;
        p.x = clamp(Math.round(p.x), 1, max);
        p.y = clamp(Math.round(p.y), 1, max);
        return p;
    }
    _hover(p) {
        const { grid } = this;
        const hoverClass = 'arche-grid-point-hover';
        grid.getElementsByClassName(hoverClass)[0]?.classList.remove(hoverClass);
        if (p) {
            grid.querySelector(`[cx="${p.x}"][cy="${p.y}"]`)?.classList.add(hoverClass);
        }
    }
}
