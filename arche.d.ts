export declare type ArcheShape = [number, number, number, number, number, number];
export interface ArcheOptions {
    readonly data?: readonly Readonly<ArcheShape>[];
}
export declare class Arche {
    private readonly options?;
    maxX: number;
    maxY: number;
    strokeWidth: number;
    data: ArcheShape[];
    private _mode;
    get mode(): "line" | "arc" | "erase";
    set mode(mode: "line" | "arc" | "erase");
    svg: SVGSVGElement;
    grid: SVGGElement;
    drawing: SVGGElement;
    private _newShapeData;
    private _newShapeElement;
    constructor(options?: ArcheOptions | undefined);
    render(): void;
    private _viewBox;
    private _createSvgElement;
    private _path;
    private _svgPointFromClient;
    private _onPointerDown;
    private _onPointerMove;
    private _onPointerCancel;
    private _onPointerUp;
    private _onPointerLeave;
}
