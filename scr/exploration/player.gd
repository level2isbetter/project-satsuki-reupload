extends CharacterBody2D

@export var enablePixelSnapping: bool = true
@onready var playerSprite: Sprite2D = get_node_or_null("PlayerSprite")

func _ready() -> void:
	if not has_node("CollisionShape2D"):
		push_warning("Player needs a CollisionShape2D child node")

func _physics_process(_delta: float) -> void:
	move_and_slide()

	if enablePixelSnapping:
		position = position.round()

func updateDirection(dir: Vector2) -> void:
	if playerSprite and dir.length() > 0:
		playerSprite.updateSpriteDirection(dir)
