extends Camera2D

@export var target: Node2D
@export var followSmoothness: float = 0.125
@export var cameraOffset: Vector2 = Vector2.ZERO
@export var zoomLevel: float = 1.0
@export var useBounds: bool = false
@export var minX: float = -500.0
@export var maxX: float = 500.0
@export var minY: float = -500.0
@export var maxY: float = 500.0

func _ready():
	zoom = Vector2(zoomLevel, zoomLevel)
	if target:
		print("Camera following: %s" % target.name)
	else:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0]
			print("Camera auto-found player: %s" % target.name)
		else:
			print("WARNING: Camera target is not set!")

func _physics_process(_delta: float):
	if target:
		followTarget()

func followTarget():
	var desiredPosition = target.global_position + cameraOffset
	if useBounds:
		desiredPosition.x = clamp(desiredPosition.x, minX, maxX)
		desiredPosition.y = clamp(desiredPosition.y, minY, maxY)
	if followSmoothness > 0:
		global_position = global_position.lerp(desiredPosition, followSmoothness)
	else:
		global_position = desiredPosition
