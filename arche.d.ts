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
    private _erasing;
    private _newShapeData;
    private _newShapeElement;
    private _clearTemporaryState;
    get size(): number;
    set size(size: number);
    get mode(): 'line' | 'arc' | 'erase';
    set mode(mode: 'line' | 'arc' | 'erase');
    constructor(options?: ArcheOptions | undefined);
    render(): void;
    private _path;
    private _svgPointFromClient;
    private _hover;
    private _onPointerDown;
    private _onPointerMove;
    private _onPointerUp;
}
