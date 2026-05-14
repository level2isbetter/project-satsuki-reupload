extends Area2D
class_name Interactable

# very heavy prototype - I guarantee this script will change a LOT

signal interacted(interactor: Node2D)
signal playerEnteredRange(player: Node2D)
signal playerExitedRange(player: Node2D)

# interaction settings of interactable
@export var interactionEnabled: bool = true
@export var interactionPrompt: String = "Press E to interact"
@export var autoInteract: bool = false
@export var oneTimeUse: bool = false
@export var interactionCooldown: float = 0.5
@export var highlightOnRange: bool = true
@export var highlightColor: Color = Color(1.0, 1.0, 0.5, 0.3)

var playerInRange: bool = false
var hasBeenUsed: bool = false
var canInteract: bool = true
var currentPlayer: Node2D = null
var cooldownTimer: float = 0.0

func _ready():
	body_entered.connect(_onBodyEntered)
	body_exited.connect(_onBodyExited)
	collision_layer = 2
	collision_mask = 1
	
	if not has_node("CollisionShape2D"):
		push_warning("Interactable '%s' needs a CollisionShape2D child node" % name)

func _process(delta: float):
	if cooldownTimer > 0:
		cooldownTimer -= delta
		if cooldownTimer <= 0:
			canInteract = true
	
	if playerInRange and canInteract and interactionEnabled:
		
		if Input.is_action_just_pressed("interact"):
			
			interact(currentPlayer)

func _onBodyEntered(body: Node2D):
	# check if the body is the player
	if body.is_in_group("player") or body.name == "Player":
		playerInRange = true
		currentPlayer = body
		playerEnteredRange.emit(body)
		
		if highlightOnRange:
			Globals.play_sfx(preload("res://aud/sfx/exploration/open.ogg"))
			applyHighlight(true)
		
		if autoInteract and canInteract and interactionEnabled:
			
			interact(body)

func _onBodyExited(body: Node2D):
	# Check if the body is the player - if so, reset state
	if body.is_in_group("player") or body.name == "Player":
		playerInRange = false
		currentPlayer = null
		playerExitedRange.emit(body)
		if highlightOnRange:
			Globals.play_sfx(preload("res://aud/sfx/exploration/close.ogg"))
			applyHighlight(false)

func interact(interactor: Node2D):
	# check if interaction is allowed - if so, 
	# perform and emit signal, then start cooldown and mark as used if one-time
	if not interactionEnabled:
		return
	
	if oneTimeUse and hasBeenUsed:
		return
	
	if not canInteract:
		return

	_onInteract(interactor)
	interacted.emit(interactor)
	if oneTimeUse:
		hasBeenUsed = true
		interactionEnabled = false
		if highlightOnRange:
			applyHighlight(false)
	
	canInteract = false
	cooldownTimer = interactionCooldown

#override this method in child classes to define specific interaction behavior
# child classes should override this though
func _onInteract(interactor: Node2D):
	print("%s interacted with %s" % [interactor.name, name])

func applyHighlight(enabled: bool):
	# apply a simple modulate highlight to the sprite
	# this is a basic implementation - customize as needed
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		if enabled:
			sprite.modulate = highlightColor
		else:
			sprite.modulate = Color.WHITE

# helper methods for child classes
func disableInteraction():
	interactionEnabled = false

func enableInteraction():
	if not (oneTimeUse and hasBeenUsed):
		interactionEnabled = true

func reset():
	hasBeenUsed = false
	interactionEnabled = true
	canInteract = true
	cooldownTimer = 0.0
