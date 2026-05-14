extends Node2D

@export var autoEnableYSort: bool = true
@export var tileWidth: float = 64.0

func _ready() -> void:
	if autoEnableYSort:
		y_sort_enabled = true

static func worldToIso(worldPos: Vector2, yRatio: float = 0.5) -> Vector2:
	var isoX: float = worldPos.x - worldPos.y
	var isoY: float = (worldPos.x + worldPos.y) * yRatio
	return Vector2(isoX, isoY)

static func isoToWorld(isoPos: Vector2, yRatio: float = 0.5) -> Vector2:
	var invRatio: float = 1.0 / yRatio
	var worldX: float = (isoPos.x + isoPos.y * invRatio) * 0.5
	var worldY: float = (isoPos.y * invRatio - isoPos.x) * 0.5
	return Vector2(worldX, worldY)

static func snapToIsoGrid(worldPos: Vector2, tileW: float = 64.0) -> Vector2:
	var tileH: float = tileW * 0.5
	var gridX: float = round(worldPos.x / tileW)
	var gridY: float = round(worldPos.y / tileH)
	return Vector2(gridX * tileW, gridY * tileH)
