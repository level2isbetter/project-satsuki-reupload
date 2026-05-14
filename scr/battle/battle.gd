extends Control

enum States {
	OPTIONS,
	PAUSE,
	SETTINGS,
	TARGETS,
	VICTORY,
	LOSS,
}

signal queue_count_changed(queue_size: int, max_size: int)

var state: States = States.OPTIONS
var settings_open: bool = false
var atb_queue: Array = []
var event_queue: Array = []
var current_player: BattlePlayerBar = null
var player_actor: BattleActor = null
var current_enemy_index: int = 0
var current_enemy: TextureButton = null
var queue_update_timer: float = 0.0
var player_sp_max: int = 100
var player_sp: int = 100
var _player_hit_tween: Tween = null
const QUEUE_UPDATE_INTERVAL: float = 0.1  # update queue display 10 times per second
const HIT_SHAKE_DISTANCE: float = 10.0
const HIT_SHAKE_TIME: float = 0.035
const HIT_FLASH_TIME: float = 0.05
const HIT_FLASH_COLOR: Color = Color(1.7, 0.65, 0.65, 1.0)

@onready var _options: WindowDefault = $Options
@onready var _options_menu: Menu = $Options/Options
@onready var _spell_menu_ui: SpellMenuUI = $SpellMenu
@onready var _enemies_menu: Menu = $AI
@onready var _players_menu: Menu = $Player
@onready var _player_info: Array = []
@onready var _crosshair: MenuCursor = $MenuCursor
@onready var _player_hp_bar: TextureProgressBar = $PlayerBars/PlayerHP/TextureProgressBar
@onready var _player_hp_label: Label = $PlayerBars/PlayerHP/HPPercent
@onready var _player_sp_bar: TextureProgressBar = $PlayerBars/PlayerSP/TextureProgressBar
@onready var _loss_menu: Control = $LossMenu
@onready var _victory_menu: Control = $VictoryMenu
@onready var _pause_menu: PauseMenu = $PauseMenu
@onready var _audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var _queue_count_label: Label = $QueueControl/QueueCount
@onready var _queue_display: HBoxContainer = $QueueControl/Queue
@onready var _player_sprite: TextureButton = $Player/BattlePlayer
@onready var _queue_slots: Array = [
	$QueueControl/Queue/QueueItem1,
	$QueueControl/Queue/QueueItem2,
	$QueueControl/Queue/QueueItem3
]

# queue icons
const PLAYER_ICON = preload("res://img/battle/ui/char/reimu/reimu_queue.png")
const ENEMY_ICON = preload("res://img/battle/ui/char/shadows/rook/rook_queue.png")

# audio
const VICTORY_SOUND = preload("res://aud/mus/Fanfare.ogg")
const LOSS_SOUND = preload("res://aud/mus/lose.ogg")

func _ready() -> void:
	
	Globals.play_music(preload("res://aud/mus/Rato.ogg"))
	Fade.fade_out()
	
	# setup audio player
	add_child(_audio_player)
	
	_player_info = [
		$PlayerATB
	]
	
	# stats from globals
	player_actor = BattleActor.new()
	player_actor.name = "Player"
	_apply_player_stats_from_virtues()
	
	# connect signals
	player_actor.hp_changed.connect(_on_player_hp_changed)
	player_actor.died.connect(_on_player_died)
	player_actor.action_queue_changed.connect(_on_player_action_queue_changed)
	queue_count_changed.connect(_on_queue_count_changed)
	_update_player_hp_bar()
	_update_player_sp_bar()

	if _spell_menu_ui:
		_spell_menu_ui.close()
		_spell_menu_ui.spell_selected.connect(_on_spell_menu_selected)
		_spell_menu_ui.cancelled.connect(_on_spell_menu_cancelled)
	
	for player in _player_info:
		player.atb_ready.connect(_on_player_atb_ready.bind(player))
	
	# connect loss menu buttons
	if _loss_menu:
		var yes_button = _loss_menu.get_node_or_null("YesButton")
		var no_button = _loss_menu.get_node_or_null("NoButton")
		if yes_button:
			yes_button.pressed.connect(_on_loss_retry)
		if no_button:
			no_button.pressed.connect(_on_loss_quit)
		_loss_menu.hide()
	
	# initialize crosshair on first enemy
	await get_tree().process_frame
	_select_enemy(0)

	if _pause_menu:
		_pause_menu.resume_requested.connect(_on_pause_resume_requested)
		_pause_menu.exit_requested.connect(_on_pause_exit_requested)
	
	# Initialize queue display
	_on_player_action_queue_changed(player_actor.action_queue.size(), player_actor.MAX_QUEUE_SIZE)

func _battle_value(index: int, default_value: int = 1) -> int:
	if Globals.battle_values is Dictionary and Globals.battle_values.has(index):
		var entry = Globals.battle_values[index]
		if entry is Dictionary:
			return int(entry.get("value", default_value))
	return default_value

func _scaled_virtue_value(index: int, fallback_battle_value: int) -> int:
	if Globals.virtue is Dictionary and Globals.virtue.has(index):
		var entry = Globals.virtue[index]
		if entry is Dictionary:
			var raw_value = int(entry.get("value", fallback_battle_value * 10))
			return int(raw_value / 10)
	return fallback_battle_value

func _apply_player_stats_from_virtues() -> void:
	# mirror global mapping: ATK=Charity(0), DEF=Chastity(1), HP=Temperance(6).
	var base_attack = _battle_value(0, 10)
	var base_defense = _battle_value(2, 10)
	var base_health = _battle_value(3, 10)

	player_actor.atk = max(_scaled_virtue_value(0, base_attack), 1)
	player_actor.def = max(_scaled_virtue_value(1, base_defense), 1)
	player_actor.maxHP = max(_scaled_virtue_value(6, base_health), 1)
	player_actor.hp = player_actor.maxHP

func _process(_delta: float) -> void:
	
	if state == States.OPTIONS or state == States.PAUSE:
		queue_update_timer += _delta
		if queue_update_timer >= QUEUE_UPDATE_INTERVAL:
			queue_update_timer = 0.0
			_update_queue_display(player_actor.action_queue.size() if player_actor else 0, player_actor.MAX_QUEUE_SIZE if player_actor else 3)

func _input(event: InputEvent) -> void:
	# handle victory click/continue (ask albert later)
	if state == States.VICTORY:
		if event is InputEventMouseButton and event.pressed:
			var viewport := get_viewport()
			_on_victory_continue()
			if viewport:
				viewport.set_input_as_handled()

func _update_queue_display(queue_size: int, max_size: int) -> void:
	var upcoming_turns = _calculate_turn_order(3)
	BattleQueue.render_slots(_queue_slots, upcoming_turns, PLAYER_ICON, ENEMY_ICON)
	queue_count_changed.emit(queue_size, max_size)

func _on_queue_count_changed(queue_size: int, max_size: int) -> void:
	if _queue_count_label:
		_queue_count_label.text = "Queued %d/%d" % [queue_size, max_size]

func _on_player_action_queue_changed(queue_size: int, max_size: int) -> void:
	_update_queue_display(queue_size, max_size)

func _calculate_turn_order(count: int) -> Array:
	return BattleQueue.calculate_turn_order(current_player, get_alive_enemies(), player_actor, count)
			
func is_atb_full() -> bool:
	# check if player atb bar is full
	if current_player and current_player.has_node("ATBBar"):
		var atb = current_player.get_node("ATBBar")
		return is_equal_approx(atb.value, atb.max_value)
	return false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# pause menu logic
		match state:
			States.OPTIONS:
				if settings_open:
					_close_settings()
					state = States.OPTIONS
				else:
					_open_settings()
					state = States.PAUSE
			States.PAUSE:
				_close_settings()
				state = States.OPTIONS
	
	# enemy cycling with up/down
	if state == States.OPTIONS:
		if event.is_action_pressed("ui_up"):
			_cycle_enemy(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			_cycle_enemy(1)
			get_viewport().set_input_as_handled()

func advance_atb_queue() -> void:
	_close_spell_menu(false)

	if current_player:
		current_player.reset()
		current_player = null
	if not atb_queue.is_empty():
		current_player = atb_queue.pop_front()
		current_player.highlight()
		
		# always show options menu
		_options.show()
		_options_menu.button_focus(0)
	else:
		get_viewport().gui_release_focus()

func _on_options_button_focused(button: BaseButton) -> void:
	pass

func _on_options_button_pressed(button: BaseButton) -> void:
	match button.name:
		"ATK":
			# attack the currently selected enemy
			if player_actor and current_enemy and is_instance_valid(current_enemy):
				var success = player_actor.queue_action("ATK", current_enemy)
				# only execute if this is the first action AND ATB is full
				if success and player_actor.action_queue.size() == 1 and current_player and is_atb_full():
					execute_queued_action()
				# refocus menu to allow more queuing
				_options_menu.button_focus(0)
			state = States.OPTIONS
		"DEF":
			if player_actor:
				var success = player_actor.queue_action("DEF")
				# only execute if this is the first action AND ATB is full
				if success and player_actor.action_queue.size() == 1 and current_player and is_atb_full():
					execute_queued_action()
				# refocus menu to allow more queuing
				_options_menu.button_focus(0)
			state = States.OPTIONS
		"SPL":
			_open_spell_menu()
		"ESC":
			_open_settings()
			state = States.PAUSE

func _on_spell_menu_selected(spell_id: String) -> void:
	_try_cast_spell(spell_id)

func _on_spell_menu_cancelled() -> void:
	_close_spell_menu()

func _open_spell_menu() -> void:
	if not _spell_menu_ui:
		return

	_spell_menu_ui.open()
	_options.hide()
	state = States.SETTINGS

func _close_spell_menu(refocus_options: bool = true, restore_options: bool = true) -> void:
	if not _spell_menu_ui:
		return

	_spell_menu_ui.close()
	if restore_options and _options:
		_options.show()
	if restore_options and refocus_options and _options_menu:
		_options_menu.button_focus(2)
	if restore_options and state != States.PAUSE:
		state = States.OPTIONS

func _try_cast_spell(spell_id: String) -> void:
	var spell_data: Dictionary = BattleSpells.get_spell(spell_id)
	if spell_data.is_empty():
		print("Unknown spell: ", spell_id)
		return

	var spell_name: String = str(spell_data.get("name", spell_id))
	var cost: int = int(spell_data.get("cost", 0))
	var damage: int = int(spell_data.get("damage", 0))

	if player_sp < cost:
		print("Not enough SP for ", spell_name)
		return

	if not player_actor:
		return

	if (not current_enemy or not is_instance_valid(current_enemy)) and not get_alive_enemies().is_empty():
		_select_enemy(0)

	if not current_enemy or not is_instance_valid(current_enemy):
		print("No valid target for ", spell_name)
		return

	var queued_spell_data := {
		"target": current_enemy,
		"damage": damage,
		"spell_name": spell_name,
		"cost": cost
	}

	var success = player_actor.queue_action("SPL", queued_spell_data)
	if not success:
		return

	player_sp -= cost
	_update_player_sp_bar()
	_close_spell_menu(false, false)

	if success and player_actor.action_queue.size() == 1 and current_player and is_atb_full():
		execute_queued_action()

	if _options_menu:
		_options_menu.button_focus(0)

func _on_player_atb_ready(player: BattlePlayerBar) -> void:
	atb_queue.append(player)
	
	if not current_player:
		advance_atb_queue()
	
	# check queued actions
	if player_actor and player_actor.has_queued_actions():
		execute_queued_action()
		
func enemy_attack(enemy_button: TextureButton) -> void:
	# called by enemy when their ATB is full
	if enemy_button and is_instance_valid(enemy_button) and enemy_button.data and player_actor:
		var damage = enemy_button.data.calculate_damage(player_actor)
		var actual_damage = player_actor.take_damage(damage)
		if actual_damage > 0 and player_actor.hp > 0:
			_play_player_hit_reaction()
		print(enemy_button.data.name + " dealt " + str(actual_damage) + " damage to " + player_actor.name)
		print("Player HP: " + str(player_actor.hp) + "/" + str(player_actor.maxHP))
		# loss is checked via player_actor.died signal

func _play_player_hit_reaction() -> void:
	if not is_instance_valid(_player_sprite):
		return

	Globals.play_sfx(preload("res://aud/sfx/battle/hitPlayer.ogg"))

	var base_position: Vector2 = _player_sprite.position

	if is_instance_valid(_player_hit_tween):
		_player_hit_tween.kill()
		_player_sprite.modulate = Color.WHITE
		_player_sprite.position = base_position

	_player_hit_tween = create_tween()
	_player_hit_tween.tween_property(_player_sprite, "modulate", HIT_FLASH_COLOR, HIT_FLASH_TIME)
	_player_hit_tween.parallel().tween_property(_player_sprite, "position", base_position + Vector2(-HIT_SHAKE_DISTANCE, 0), HIT_SHAKE_TIME)
	_player_hit_tween.tween_property(_player_sprite, "position", base_position + Vector2(HIT_SHAKE_DISTANCE, 0), HIT_SHAKE_TIME)
	_player_hit_tween.parallel().tween_property(_player_sprite, "modulate", Color.WHITE, HIT_FLASH_TIME)
	_player_hit_tween.tween_property(_player_sprite, "position", base_position, HIT_SHAKE_TIME)

func execute_queued_action() -> void:
	# execute/pop next action on full player bar
	if not current_player or not player_actor:
		return
	
	if not player_actor.has_queued_actions():
		return
	
	# pop the next action
	var action = player_actor.pop_action()
	_update_queue_display(player_actor.action_queue.size(), player_actor.MAX_QUEUE_SIZE)
	if action.is_empty():
		return
	
	# end defending from previous turn
	player_actor.end_defending()
	
	# execute the action
	match action["type"]:
		"ATK":
			var target = _resolve_queued_target(action.get("target"))
			if target and is_instance_valid(target) and target.has_method("take_damage"):
				var damage = player_actor.calculate_damage(target.data)
				var actual_damage = target.take_damage(damage)
				print(player_actor.name + " dealt " + str(actual_damage) + " damage to " + target.data.name)
				# update crosshair position after damage (enemy may have died)
				_update_crosshair()
				# check for victory after dealing damage
				check_victory()
			else:
				print("Target no longer valid, action wasted")
		
		"DEF":
			player_actor.start_defending()
			print(player_actor.name + " is defending! (50% damage reduction)")
		"SPL":
			var spell_data = action.get("target", {})
			if not (spell_data is Dictionary):
				print("Invalid spell action data")
				return

			var target = _resolve_queued_target(spell_data.get("target"))
			var spell_damage: int = int(spell_data.get("damage", 0))
			var spell_name: String = str(spell_data.get("spell_name", "Spell"))
			spell_data = spell_data.duplicate(true)
			spell_data["target"] = target

			if target and is_instance_valid(target) and target.has_method("take_damage"):
				var actual_damage = target.take_damage(spell_damage)
				print(player_actor.name + " cast " + spell_name + " for " + str(actual_damage) + " damage on " + target.data.name)
				_update_crosshair()
				check_victory()
			else:
				print(spell_name + " target no longer valid, action wasted")
	
	# reset ATB but keep menu focused
	if current_player:
		current_player.reset()
		# keep menu open and focused
		_options.show()
		_options_menu.button_focus(0)

func _resolve_queued_target(original_target) -> TextureButton:
	if original_target and is_instance_valid(original_target) and original_target in get_alive_enemies():
		return original_target

	if current_enemy and is_instance_valid(current_enemy) and current_enemy in get_alive_enemies():
		return current_enemy

	var alive_enemies = get_alive_enemies()
	if not alive_enemies.is_empty():
		return alive_enemies[0]

	return null

func _open_settings() -> void:
	settings_open = true
	if _pause_menu:
		_pause_menu.open()
	get_tree().paused = true
	
func _close_settings() -> void:
	if _pause_menu:
		_pause_menu.close()
	settings_open = false
	get_tree().paused = false

func _on_pause_resume_requested() -> void:
	_close_settings()
	state = States.OPTIONS

func _on_pause_exit_requested() -> void:
	get_tree().quit()

func _on_player_button_pressed(button: TextureButton) -> void:
	advance_atb_queue()

func _on_player_hp_changed(hp: int, change: int) -> void:
	# update HP bar when player takes damage or heals
	_update_player_hp_bar()

func _update_player_hp_bar() -> void:
	if _player_hp_bar and player_actor:
		_player_hp_bar.max_value = player_actor.maxHP
		_player_hp_bar.value = player_actor.hp
		
		if _player_hp_label and player_actor:
			var hp_percent = (float(player_actor.hp) / float(player_actor.maxHP)) * 100.0
			_player_hp_label.text = str(int(hp_percent)) + "%"

func _update_player_sp_bar() -> void:
	if _player_sp_bar:
		_player_sp_bar.max_value = float(player_sp_max)
		_player_sp_bar.value = float(player_sp)

func get_alive_enemies() -> Array:
	# get all enemy buttons that are still alive
	var alive_enemies = []
	for enemy in _enemies_menu.get_children():
		if is_instance_valid(enemy) and enemy.data and enemy.data.hp > 0:
			alive_enemies.append(enemy)
	return alive_enemies

func check_victory() -> void:
	# check if all enemies are defeated
	if state == States.VICTORY or state == States.LOSS:
		return
	
	var alive_enemies = get_alive_enemies()
	if alive_enemies.is_empty():
		activate_victory()

func activate_victory() -> void:
	state = States.VICTORY
	
	Fade.fade_out(1.5, Color.WHITE)
	
	# stop all ATB processing
	stop_battle()
	BattleResults.show_outcome(
		_options,
		_crosshair,
		_spell_menu_ui,
		_victory_menu,
		_audio_player,
		VICTORY_SOUND,
		"VICTORY",
		"All enemies defeated!"
	)

func _on_victory_continue() -> void:
	if state != States.VICTORY:
		return

	# lock out repeated clicks during handoff
	state = States.OPTIONS
	BattleResults.continue_from_victory(_victory_menu, _audio_player)
	
	Fade.fade_in($tmrBackToExploration.wait_time, Color.WHITE)
	$tmrBackToExploration.start()

func _on_player_died() -> void:
	if state == States.VICTORY or state == States.LOSS:
		return
	
	activate_loss()

func activate_loss() -> void:
	state = States.LOSS
	
	Fade.fade_out($tmrDeadHoldup.wait_time, Color.RED)
	Globals.stop_music()
	_audio_player.stop()
	Globals.play_sfx(preload("res://aud/sfx/battle/dead.ogg"))
	$tmrDeadHoldup.start()
	
	# stop all ATB processing
	stop_battle()

func stop_battle() -> void:
	# stop all ATB bars from processing
	for player in _player_info:
		if player.has_node("ATBBar"):
			player.get_node("ATBBar").set_process(false)
	
	# stop all enemy ATB bars
	for enemy in _enemies_menu.get_children():
		if is_instance_valid(enemy) and enemy.has_node("ATBBar"):
			enemy.get_node("ATBBar").set_process(false)
	
	# clear ATB queue
	atb_queue.clear()
	current_player = null
	
func _on_tmr_dead_holdup_timeout() -> void:
	if state != States.LOSS:
		return

	BattleResults.show_outcome(
		_options,
		_crosshair,
		_spell_menu_ui,
		_loss_menu,
		_audio_player,
		LOSS_SOUND,
		"DEFEAT",
		"Player has been defeated!"
	)

func _on_loss_retry() -> void:
	get_tree().reload_current_scene()

func _on_loss_quit() -> void:
	Globals.restart()

func _cycle_enemy(direction: int) -> void:
	# cycle through alive enemies with up/down
	var alive_enemies = get_alive_enemies()
	if alive_enemies.is_empty():
		return
	
	current_enemy_index = (current_enemy_index + direction) % alive_enemies.size()
	if current_enemy_index < 0:
		current_enemy_index = alive_enemies.size() - 1
	
	_select_enemy(current_enemy_index)

func _select_enemy(index: int) -> void:
	# select an enemy and position crosshair on it
	var alive_enemies = get_alive_enemies()
	if alive_enemies.is_empty():
		current_enemy = null
		_crosshair.hide()
		return
	
	index = clamp(index, 0, alive_enemies.size() - 1)
	current_enemy_index = index
	current_enemy = alive_enemies[index]
	
	# position crosshair on enemy
	_crosshair.target = current_enemy
	_crosshair.show()
	_crosshair.set_process(true)

func _update_crosshair() -> void:
	# update crosshair position if enemy dies or changes
	var alive_enemies = get_alive_enemies()
	
	# if current enemy is dead or invalid, select next alive enemy
	if not is_instance_valid(current_enemy) or current_enemy not in alive_enemies:
		if not alive_enemies.is_empty():
			_select_enemy(0)
		else:
			_crosshair.hide()


func _on_tmr_back_to_exploration_timeout() -> void:
	Globals.startExploration("world1", 0, 0, 0)
