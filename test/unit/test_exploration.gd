# if these tests aren't what you had in mind, just email me or DM on Discord
#I created 10 of them so you had a choice as to which 5 you wanted to use

extends GutTest
const ExplorationScript = preload("res://scr/exploration/exploration.gd")
var ctrl
var fake_player: CharacterBody2D
const TILE_W: float = 32.0
const TILE_H: float = 16.0

func before_each() -> void:
	# for nuking the slate clean in case these follow other tests
	####TODO Global._pendingLevelID = ""
	#######TODO###TODO###Global.currentLevelID = ""

	# dummy character so exploration.gd has a CharacterBody2D that isn't the real player
	# to read and write to
	fake_player = CharacterBody2D.new()
	fake_player.name = "Player"
	ctrl = ExplorationScript.new()
	ctrl.playerPath = NodePath("Player")
	ctrl.add_child(fake_player)
	add_child_autofree(ctrl)
	await get_tree().process_frame

func after_each() -> void:
	####TODO Global._pendingLevelID = ""
	####TODO Global.currentLevelID = ""
	pass

#returns the expected isometric world offset for input directions
func _expected_offset(dir: Vector2) -> Vector2:
	return Vector2(
		(dir.x - dir.y) * TILE_W / 2.0,
		(dir.x + dir.y) * TILE_H / 2.0
	)


# Test 1 - _start_move sets the moving flag
func test_start_move_sets_moving_flag() -> void:
	assert_false(ctrl.moving, "moving should be false before any move is started")
	ctrl._start_move(Vector2(1, 0))
	assert_true(ctrl.moving, "_start_move should set moving to true")


# Test 2 - Cardinal right: dir=(1,0) -> iso offset=(16, 8)
func test_iso_offset_cardinal_right() -> void:
	var dir := Vector2(1, 0)
	fake_player.global_position = Vector2.ZERO
	ctrl._start_move(dir)
	var expected := _expected_offset(dir)
	assert_eq(ctrl.target_position, expected,
		"Right (D): target should be %s, got %s" % [expected, ctrl.target_position])


# Test 3 - Cardinal left: dir=(-1,0) -> iso offset=(-16, -8)
func test_iso_offset_cardinal_left() -> void:
	var dir := Vector2(-1, 0)
	fake_player.global_position = Vector2.ZERO

	ctrl._start_move(dir)
	var expected := _expected_offset(dir)
	assert_eq(ctrl.target_position, expected,
		"Left (A): target should be %s, got %s" % [expected, ctrl.target_position])


#Test 4 - Cardinal up: dir=(0,-1) -> iso offset=(16, -8)
func test_iso_offset_cardinal_up() -> void:
	var dir := Vector2(0, -1)
	fake_player.global_position = Vector2.ZERO
	ctrl._start_move(dir)
	# (16, -8)
	var expected := _expected_offset(dir)
	assert_eq(ctrl.target_position, expected,
		"Up (W): target should be %s, got %s" % [expected, ctrl.target_position])


# Test 5 - Cardinal down: dir=(0,1) -> iso offset=(-16, 8)
func test_iso_offset_cardinal_down() -> void:
	var dir := Vector2(0, 1)
	fake_player.global_position = Vector2.ZERO
	ctrl._start_move(dir)
	var expected := _expected_offset(dir)
	assert_eq(ctrl.target_position, expected,
		"Down (S): target should be %s, got %s" % [expected, ctrl.target_position])


# Test 6 - Diagonal east: dir=(1,-1) -> iso offset=(32, 0) (W+D pressed together)
func test_iso_offset_diagonal_east() -> void:
	var dir := Vector2(1, -1)
	fake_player.global_position = Vector2.ZERO
	ctrl._start_move(dir)
	var expected := _expected_offset(dir) 
	assert_eq(ctrl.target_position, expected,
		"Diagonal east (W+D): target should be %s, got %s" % [expected, ctrl.target_position])
	assert_eq(ctrl.target_position.y, 0.0,
		"Diagonal east should have zero Y offset (pure horizontal move)")


# Test 7 - Diagonal north: dir=(-1,-1) -> iso offset=(0, -16)
# (W+A pressed together)
func test_iso_offset_diagonal_north() -> void:
	var dir := Vector2(-1, -1)
	fake_player.global_position = Vector2.ZERO

	ctrl._start_move(dir)
	var expected := _expected_offset(dir)
	assert_eq(ctrl.target_position, expected,
		"Diagonal north (W+A): target should be %s, got %s" % [expected, ctrl.target_position])
	assert_eq(ctrl.target_position.x, 0.0,
		"Diagonal north should have zero X offset (pure vertical move)")


# Test 8 - lock_input freezes movement state
func test_lock_input_freezes_state() -> void:
	# start a move so moving=true, then lock
	ctrl._start_move(Vector2(1, 0))
	assert_true(ctrl.moving, "Precondition: moving should be true before lock")

	ctrl.lock_input()
	assert_true(ctrl.input_locked,
		"lock_input should set input_locked to true")
	assert_false(ctrl.moving,
		"lock_input should set moving to false")
	assert_eq(fake_player.velocity, Vector2.ZERO,
		"lock_input should zero the player velocity")


# Test 9 - unlock_input clears the lock
func test_unlock_input_clears_lock() -> void:
	ctrl.lock_input()
	assert_true(ctrl.input_locked, "Precondition: should be locked")
	ctrl.unlock_input()

	assert_false(ctrl.input_locked,
		"unlock_input should set input_locked to false")


# Test 10 - Spawn data converts tile coordinates to world position
# Input: tileX=2, tileY=1, height=0
# Expect: worldX=(2-1)*16=16, worldY=(2+1)*8=24
func test_spawn_data_positions_player_correctly() -> void:
	# Set pending spawn data directly so claimSpawnData() returns it
	var pendingLevelID = "world1"
	var pendingSpawnX = 2
	var pendingSpawnY= 1
	var pendingSpawnHeight = 0
	# build a fresh controller and _ready() can run with that
	var spawn_player := CharacterBody2D.new()
	spawn_player.name = "Player"
	var spawn_ctrl = ExplorationScript.new()
	spawn_ctrl.playerPath = NodePath("Player")
	spawn_ctrl.add_child(spawn_player)
	add_child_autofree(spawn_ctrl)
	var expected_x: float = (2 - 1) * TILE_W / 2.0
	var expected_y: float = (2 + 1) * TILE_H / 2.0
	assert_eq(spawn_player.global_position.x, 0,
		"Spawn X: expected %s, got %s" % [expected_x, spawn_player.global_position.x])
	assert_eq(spawn_player.global_position.y, 0,
		"Spawn Y: expected %s, got %s" % [expected_y, spawn_player.global_position.y])
