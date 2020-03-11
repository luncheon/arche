export declare type ArcheShape = [number, number, number, number, number, number];
export interface ArcheOptions {
    readonly data?: readonly Readonly<ArcheShape>[];
}
export declare class Arche {
    private readonly options?;
    data: ArcheShape[];
    svg: SVGSVGElement;
    grid: SVGGElement;
    drawing: SVGGElement;
    private _newShapeData;
    private _newShapeElement;
    private _hoverClass;
    get size(): number;
    set size(size: number);
    get mode(): 'line' | 'arc' | 'erase';
    set mode(mode: 'line' | 'arc' | 'erase');
    constructor(options?: ArcheOptions | undefined);
    render(): void;
    private _createSvgElement;
    private _path;
    private _svgPointFromClient;
    private _preventDefault;
    private _onClick;
    private _onPointerDown;
    private _onPointerMove;
    private _onPointerCancel;
    private _onPointerUp;
    private _onPointerLeave;
}
