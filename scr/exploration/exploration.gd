extends Node2D

@export var tile_size: Vector2 = Vector2(32, 16)
@export var move_speed: float = 200.0
@export var playerPath: NodePath = NodePath("Player")
@onready var player: CharacterBody2D = get_node(playerPath)

var target_position: Vector2
var moving := false
var input_locked := false
var current_dir: Vector2 = Vector2.ZERO
var _last_position: Vector2 = Vector2.ZERO
var _stuck_timer: float = 0.0
const STUCK_TIMEOUT: float = 0.15
#implement EncounterTable later - I do not have enough time right now


func _ready() -> void:

	## This condition was created
	## SPECIFICALLY because the
	## parameters would've been init'ed
	## if we ran it from a bridge transition
	##
	## But this isn't the case if running
	## directly through F6.
	if Globals.debug_f6:
		Globals.parameters = {
			"levelID": "world1",
			"x": 0,
			"y": 0,
			"height": 0
		}
		
	Globals.play_music(preload("res://aud/mus/DisSlaos.ogg"))
		
	Fade.fade_out(1.0, Color.WHITE)
	
	target_position = player.global_position
	_applySpawnData()
	_connectInteractables()

# positions the spawn of the character
func _applySpawnData() -> void:
	var data: Dictionary = Globals.parameters
	
	print(data)
	if data["levelID"] == "":
		# if true, no pending spawn exists, keep default editor position
		return 

	var tileX: int = data["x"]
	var tileY: int = data["y"]
	var height: int = data["height"]

	var worldX: float = (tileX - tileY) * (tile_size.x / 2.0)
	var worldY: float = (tileX + tileY) * (tile_size.y / 2.0) - height * tile_size.y

	player.global_position = Vector2(worldX, worldY)
	target_position = player.global_position

func _connectInteractables() -> void:
	await get_tree().process_frame

	var interactables: Array[Node] = get_tree().get_nodes_in_group("npc")
	interactables.append_array(get_tree().get_nodes_in_group("interactable"))

	for node in interactables:
		if node.has_signal("playerEnteredRange") and node.has_signal("playerExitedRange"):
			if not node.playerEnteredRange.is_connected(_onInteractableEnter):
				node.playerEnteredRange.connect(_onInteractableEnter.bind(node))
			if not node.playerExitedRange.is_connected(_onInteractableExit):
				node.playerExitedRange.connect(_onInteractableExit)

func _onInteractableEnter(_p: Node2D, interactable: Node) -> void:
	var promptUI: PanelContainer = get_node_or_null("UI/InteractionPrompt")
	if promptUI and interactable.get("interactionPrompt") != null:
		promptUI.showPrompt(interactable.interactionPrompt)

func _onInteractableExit(_p: Node2D) -> void:
	var promptUI: PanelContainer = get_node_or_null("UI/InteractionPrompt")
	if promptUI:
		promptUI.hidePrompt()

# input and movement mapping
func _process(delta: float) -> void:
	
	if input_locked:
		return

	if moving:
		_move_player(delta)
	else:
		_handle_input()

func _handle_input() -> void:
	var x_input: int = 0
	var y_input: int = 0

	if Input.is_action_pressed("ui_right"):
		x_input += 1
	if Input.is_action_pressed("ui_left"):
		x_input -= 1
	if Input.is_action_pressed("ui_up"):
		y_input -= 1
	if Input.is_action_pressed("ui_down"):
		y_input += 1

	if x_input != 0 or y_input != 0:
		_start_move(Vector2(x_input, y_input))

func _start_move(dir: Vector2) -> void:
	current_dir = dir
	var iso_offset := Vector2(
		(dir.x - dir.y) * tile_size.x / 2,
		(dir.x + dir.y) * tile_size.y / 2
	)
	target_position = player.global_position + iso_offset
	moving = true

func _move_player(delta: float) -> void:
	var diff := target_position - player.global_position

	# handles 8-directional animations. Not too sure how to go about this
	#in the event of multiframe 8-dimensional animations.
	# ^ for a later date
	player.updateDirection(current_dir)

	# bandage in case the player gets stuck on a corner or something, by checking 
	# if they haven't moved much for a short time, and if so, just snap to the target
	var moved_this_frame := player.global_position.distance_to(_last_position)
	if moved_this_frame < 0.5:
		_stuck_timer += delta
	else:
		_stuck_timer = 0.0
	_last_position = player.global_position

	if diff.length() <= move_speed * delta or _stuck_timer >= STUCK_TIMEOUT:
		# reached target, or blocked long enough - snap and stop
		player.velocity = Vector2.ZERO
		#if stuck, stay at actual position rather than teleporting into a wall
		#yes this was a bug I encountered, yes this was necessary.
		if _stuck_timer < STUCK_TIMEOUT:
			player.global_position = target_position
		moving = false
		_stuck_timer = 0.0
		_onStepCompleted()
	else:
		player.velocity = diff.normalized() * move_speed

#wall of comments because I need to push this to main and I don't 
#have time to implement encounters right now
func _onStepCompleted() -> void:
	print("Step completed at position: %s" % player.global_position)
#	var levelID: String = Global.currentLevelID
#	if not EncounterTable.battlesEnabled(levelID):
#		return
#
#	if randf() >= EncounterTable.getEncounterRate(levelID):
#		return  # No encounter this step
#
#	# roll how many enemies (1-3) then pick each one from the weighted table
#	var count: int = randi_range(1, 3)
#	var enemyIDs: Array = []
#	for i in range(count):
#		var picked: String = EncounterTable.pickEnemy(levelID)
#		if picked != "":
#			enemyIDs.append(picked)
#
#	# fallback: if every pick somehow returned empty, use the first table entry
#	if enemyIDs.is_empty():
#		var table: Dictionary = EncounterTable.getTable(levelID)
#		var enemies: Array = table.get("enemies", [])
#		if not enemies.is_empty():
#			enemyIDs.append(enemies[0]["id"])


#external controls
func lock_input() -> void:
	input_locked = true
	moving = false
	player.velocity = Vector2.ZERO

func unlock_input() -> void:
	input_locked = false
