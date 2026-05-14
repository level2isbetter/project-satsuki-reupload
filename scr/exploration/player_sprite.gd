extends Sprite2D
@export var spriteDown: Texture2D
@export var spriteDownRight: Texture2D
@export var spriteRight: Texture2D
@export var spriteUpRight: Texture2D
@export var spriteUp: Texture2D
@export var spriteUpLeft: Texture2D
@export var spriteLeft: Texture2D
@export var spriteDownLeft: Texture2D


# Used if a directional sprite is missing. Shouldn't happen
# but this just helps foolproof it
@export var spriteFallback: String = "res://img/mayumi.png"

@export var spriteScale: Vector2 = Vector2(1.0, 1.0)

#all directions
enum Direction { DOWN, DOWN_RIGHT, RIGHT, UP_RIGHT, UP, UP_LEFT, LEFT, DOWN_LEFT }

var currentDirection: int = Direction.DOWN
var directionTextures: Array = []

func _ready() -> void:
	setupSprite()
	loadDirectionTextures()
	showDirection(currentDirection)

func setupSprite() -> void:
	scale = spriteScale
	centered = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func loadDirectionTextures() -> void:
	# build the texture array in direction enum order
	directionTextures = [
		spriteDown,
		spriteDownRight,
		spriteRight,
		spriteUpRight,
		spriteUp,
		spriteUpLeft,
		spriteLeft,
		spriteDownLeft
	]
	
	# load fallback texture for any missing directions
	var fallback: Texture2D = null
	for i in range(directionTextures.size()):
		if directionTextures[i] == null:
			# lazy load the fallback only if needed
			if fallback == null:
				fallback = load(spriteFallback) as Texture2D
				if fallback == null:
					push_error("Fallback sprite not found: %s" % spriteFallback)
					fallback = createFallbackTexture()
			directionTextures[i] = fallback
			push_warning("Direction %d has no texture assigned - using fallback" % i)

func createFallbackTexture() -> ImageTexture:
	var img: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.5, 0.8))
	return ImageTexture.create_from_image(img)


# called by player.gd every physics frame when moving
# not ideal, but it works.
func updateSpriteDirection(_movementDir: Vector2) -> void:
	var angle: float = _movementDir.angle()
	var newDir: int = angleToDirection(angle)
	
	if newDir != currentDirection:
		currentDirection = newDir
		showDirection(currentDirection)

func angleToDirection(angle: float) -> int:
	var degrees: float = rad_to_deg(angle)
	
	# normalize to 0-360
	if degrees < 0.0:
		degrees += 360.0
	
	if degrees < 22.5 or degrees >= 337.5:
		return Direction.RIGHT
	elif degrees < 67.5:
		return Direction.DOWN_RIGHT
	elif degrees < 112.5:
		return Direction.DOWN
	elif degrees < 157.5:
		return Direction.DOWN_LEFT
	elif degrees < 202.5:
		return Direction.LEFT
	elif degrees < 247.5:
		return Direction.UP_LEFT
	elif degrees < 292.5:
		return Direction.UP
	else:
		return Direction.UP_RIGHT

func showDirection(dir: int) -> void:
	if directionTextures.size() == 0:
		return
	texture = directionTextures[dir]


func setFacingDirection(facingRight: bool) -> void:
	flip_h = not facingRight
