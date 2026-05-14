extends CharacterBody2D
class_name Enemy

# enemy that patrols, detects the player, chases, and hands off to Nama.
# Combat itself is handled by the battle scene via Global.startBattle().

# note: startBattle() functionally crashes the exploration scene right now.
# That's by design. Simply hand it off to the battle mechanic from there and it
# should work.

@export var enemyID: String = ""
@export var enemyName: String = "Enemy"
@export var moveSpeed: float = 80.0
@export var detectionRange: float = 150.0
# these are for patrols. the patrol movement is a little janky since it
#only scoots back and forth - feel free to let me know if this needs adjustment
#idk if we even need patrols, but if we do, this is a starting point.
@export var patrolEnabled: bool = true
@export var patrolDistance: float = 64.0
@export var patrolSpeed: float = 40.0
# MUST be larger than the sum of the enemy's collision radius (which is 46px) and the
# player's collision radius (16px), otherwise the enemy will cause a loop of detecting and losing the player as 
#they jitter on the edge of detection range. Adjust as your own peril.
@export var combatInitiationDistance: float = 70.0

signal playerDetected(player: Node2D)
signal playerLost()
enum State { PATROL, CHASE, WAITING }
var currentState: int = State.PATROL
var currentPlayer: Node2D = null
var patrolOrigin: Vector2 = Vector2.ZERO
var patrolDirection: Vector2 = Vector2.RIGHT
var patrolTravelled: float = 0.0
var hasInitiatedCombat: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var detectionArea: Area2D = get_node_or_null("DetectionArea")

func _ready() -> void:
	patrolOrigin = global_position

	if detectionArea:
		detectionArea.body_entered.connect(_onDetectionEntered)
		detectionArea.body_exited.connect(_onDetectionExited)

		var detectionShape: CollisionShape2D = detectionArea.get_node_or_null("CollisionShape2D")
		if detectionShape and detectionShape.shape is CircleShape2D:
			detectionShape.shape.radius = detectionRange
	else:
		# should never get this, but if you do get this warning, revert whatever change you made 
		push_warning("%s needs a DetectionArea child (Area2D with CollisionShape2D)" % enemyName)

func _physics_process(delta: float) -> void:
	if currentState == State.WAITING:
		return

	match currentState:
		State.PATROL:
			handlePatrol(delta)
		State.CHASE:
			handleChase(delta)

	move_and_slide()

#governs patrol and chase mechanics of non-random enemies already in the map. R
# right now, the enemy just scoots, but if you want to change that, these are the
# functions to edit.
func handlePatrol(delta: float) -> void:
	if not patrolEnabled:
		velocity = Vector2.ZERO
		return

	velocity = patrolDirection * patrolSpeed
	patrolTravelled += patrolSpeed * delta

	if patrolTravelled >= patrolDistance:
		patrolDirection = -patrolDirection
		patrolTravelled = 0.0

	flipSprite(velocity.x)

func handleChase(_delta: float) -> void:
	if currentPlayer == null:
		setState(State.PATROL)
		return

	var distanceToPlayer: float = global_position.distance_to(currentPlayer.global_position)

	if distanceToPlayer <= combatInitiationDistance:
		initiateCombat()
		return

	var direction: Vector2 = (currentPlayer.global_position - global_position).normalized()
	velocity = direction * moveSpeed
	flipSprite(velocity.x)

# combat handoff
func initiateCombat() -> void:
	if hasInitiatedCombat:
		return

	hasInitiatedCombat = true
	velocity = Vector2.ZERO
	setState(State.WAITING)

	if enemyID == "":
		push_warning("%s has no enemyID set - battle will launch with an empty enemy slot." % enemyName)

	print("[Battle] Initiating combat with %s (ID: %s)" % [enemyName, enemyID])
	
	$tmrEnemyTransition.start()
	Fade.fade_enemy()
	Globals.stop_music()
	Globals.play_sfx(preload("res://aud/sfx/exploration/transition_enemy.ogg"))
	
func _on_tmr_enemy_transition_timeout() -> void:
	Globals.startBattle([enemyID])

# governs whether the player has entered the enemy's detection area to
# initiate chase

func _onDetectionEntered(body: Node2D) -> void:
	if body.is_in_group("player"):
		currentPlayer = body
		setState(State.CHASE)
		playerDetected.emit(body)
		print("[Enemy] %s detected the player." % enemyName)

func _onDetectionExited(body: Node2D) -> void:
	if body.is_in_group("player") and currentState != State.WAITING:
		# bandaid for the bug mentioned before. The exit signal can fire spuriously 
		# when physics causes jitter between two CharacterBody2D nodes. Makes it so enemy
		# only actually gives up chase if the player is genuinely outside detection range, 
		#not just due to collision noise.
		var actualDistance: float = global_position.distance_to(body.global_position)
		if actualDistance > detectionRange:
			currentPlayer = null
			setState(State.PATROL)
			playerLost.emit()
			print("[Enemy] %s lost sight of the player." % enemyName)

func setState(newState: int) -> void:
	currentState = newState
	if newState == State.PATROL:
		hasInitiatedCombat = false

func flipSprite(xVelocity: float) -> void:
	if sprite and xVelocity != 0.0:
		sprite.flip_h = xVelocity < 0.0

func resetCombat() -> void:
	hasInitiatedCombat = false
	setState(State.PATROL)
	currentPlayer = null
