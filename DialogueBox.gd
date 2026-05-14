extends Control

@onready var text_label: RichTextLabel = $Panel/VBoxContainer/RichTextLabel
@onready var name_label: Label = $Panel/NamePlate/NameLabel
@onready var choices_container: VBoxContainer = $Panel/VBoxContainer/ChoicesContainer
@onready var choice_button_scene: PackedScene = preload("res://sce/conversation/ChoiceButton.tscn")

@onready var sword_sprite: Sprite2D = $Node2D/Sword
@onready var bg: Sprite2D = $Node2D/Background
@onready var bg_fade: ColorRect = $BGFade
@onready var character_manager: CharacterManager = $Node2D/CharacterManager

@onready var pause_button: Button = $Panel/VBoxContainer/OptionsBar/PauseButton
@onready var save_button: Button = $Panel/VBoxContainer/OptionsBar/SaveButton


# ------------------------
# DATA
# ------------------------
var bg_textures := {
	"default": preload("res://shrinebg.jpg"),
	"shop": preload("res://shop.jpg"),
}

var move_out_parameters := ["", 0, 0, 0]

var current_bg_key: String = "default"

@export var pause_dim_alpha: float = 0.6
@export var display_speed := 20.0

var character_defs := {
	"reimu": {
		"display_name": "Reimu",
		"body": preload("res://img/conversation/char/reimu/base.png"),
		"default_expression": "neutral",
		"expressions": {
			"neutral": {
				"eyes": preload("res://img/conversation/char/reimu/eyelashes/mood_right.png"),
				"mouth": preload("res://img/conversation/char/reimu/mouths/mood.png")
			},
			"happy": {
				"eyes": preload("res://img/conversation/char/reimu/eyelashes/normal.png"),
				"mouth": preload("res://img/conversation/char/reimu/mouths/happy.png")
			},
			"sad": {
				"eyes": preload("res://img/conversation/char/reimu/eyelashes/worried_down.png"),
				"mouth": preload("res://img/conversation/char/reimu/mouths/sad.png")
			}
		}
	},

	"shopkeeper": {
		"display_name": "Satsuki",
		"body": preload("res://img/conversation/char/satsuki/base.png"),
		"default_expression": "neutral",
		"expressions": {
			"neutral": {
				"eyes": preload("res://img/conversation/char/satsuki/eyelashes/angry_left.png"),
				"mouth": preload("res://img/conversation/char/satsuki/mouths/sad.png")
			}
		}
	},
	"rumia": {
		"display_name": "Rumia",
		"body": preload("res://img/conversation/char/rumia/base.png"),
		"default_expression": "neutral",
		"expressions": {
			"neutral": {
				"eyes": preload("res://img/conversation/char/rumia/eyelashes/normal_middleleft.png"),
				"mouth": preload("res://img/conversation/char/rumia/mouths/happy.png")
			},
			"angry": {
				"eyes": preload("res://img/conversation/char/rumia/eyelashes/angry_bottomleft.png"),
				"mouth": preload("res://img/conversation/char/rumia/mouths/sad.png")
			}
		}
	}	
}
# ------------------------
# Events
# ------------------------
var events = {
	0: {
		"name": "intro",
		"actions": [
			{"type": "set_bg", "key": "default"},
			{
				"type": "character_show",
				"id": "reimu",
				"slot": "left",
				"expression": "neutral",
				"from": Vector2(-300, 620),
				"duration": 0.5
			},
			{
				"type": "character_hide",
				"id": "shopkeeper",
				"duration": 0.2
			}
		],
		"text": [
			{"character": "Reimu", "text": "Hey there!"},
			{"character": "Reimu", "text": "This is a test for the conversation mechanic."},
			{"character": "Reimu", "text": "Press SPACE or ENTER to continue."}
		],
		"next_event": 1
	},

	1: {
		"name": "conversation with choices",
		"text": [
			{"character": "Reimu", "text": "Do you want to help me?"},
			{"character": "Reimu", "text": "What will you choose?"}
		],
		"choices": [
			{"text": "Yes, I will help you!", "next_event": 2},
			{"text": "No, I can't help.", "next_event": 3}
		]
	},

	2: {
		"name": "Thanks for helping",
		"actions": [
			{"type": "character_expression", "id": "reimu", "expression": "happy"},
			{"type": "character_shake", "id": "reimu", "duration": 0.5, "magnitude": 10.0}
		],
		"text": [
			{"character": "Reimu", "text": "Thank you so much! Let's do this!"}
		],
		"next_event": 4
	},

	3: {
		"name": "Refusal",
		"actions": [
			{"type": "character_expression", "id": "reimu", "expression": "sad"}
		],
		"text": [
			{"character": "Reimu", "text": "Oh... okay. Maybe next time."}
		],
		"next_event": 7
	},

	7: {
		"name": "Refusal Hub",
		"actions": [
			{"type": "character_hide", "id": "shopkeeper", "duration": 0.5, "if_bg": "shop"},
			{"type": "fade_out", "duration": 0.35, "if_bg": "shop"},
			{"type": "set_bg", "key": "default", "if_bg": "shop"},
			{"type": "fade_in", "duration": 0.35, "if_bg": "shop"}
		],
		"text": [
			{"character": "Reimu", "text": "So what now?"}
		],
		"choices": [
			{"text": "Return to overworld", "next_event": 99},
			{"text": "Go to shop", "next_event": 8}
		]
	},

	8: {
		"name": "Shop",
		"actions": [
			{"type": "fade_out", "duration": 0.35},
			{"type": "set_bg", "key": "shop"},
			{"type": "character_expression", "id": "reimu", "expression": "neutral"},
			{
				"type": "character_show",
				"id": "shopkeeper",
				"slot": "right",
				"expression": "neutral",
				"from": Vector2(1600, 620),
				"duration": 0.7
			},
			{"type": "fade_in", "duration": 0.35}
		],
		"text": [
			{"character": "Reimu", "text": "Fine… let’s at least check the shop."},
			{"character": "Shopkeeper", "text": "Welcome! Looking for anything special?"},
			{"character": "Reimu", "text": "Do you sell anything of value?"}
		],
		"choices": [
			{"text": "Leave the shop", "next_event": 13},
			{"text": "Slowly leave the shop", "next_event": 9}
		]
	},

	99: {
		"name": "Overworld",
		"actions": [
		{"type": "go_to_exploration",
			"type_name": "world1",
			"level": 0,
			"x": 0,
			"y": 0
			}
		],
		"text": [
			{"character": "", "text": "You return to the overworld (placeholder).[exploration]['world1',0,0,0]"}
		]
	},

	4: {
		"name": "Found Sword",
		"actions": [
			{"type": "sword_show_anim"}
		],
		"text": [
			{"character": "Reimu", "text": "Wait… what’s that on the ground?"},
			{"character": "Reimu", "text": "It's a shiny sword!"}
		],
		"choices": [
			{"text": "Take the sword", "next_event": 5},
			{"text": "Leave it", "next_event": 6}
		]
	},

	5: {
		"name": "Take Sword",
		"actions": [
			{"type": "sword_hide", "duration": 0.4}
		],
		"text": [
			{"character": "Reimu", "text": "I'll take it! This will help us."}
		]
	},

	6: {
		"name": "Leave Sword",
		"actions": [
			{"type": "sword_hide", "duration": 0.4}
		],
		"text": [
			{"character": "Reimu", "text": "Better not touch it..."}
		]
	},
	
	9: {
		"name": "Shop Exit Quest",
		"actions": [
			{"type": "fade_out", "duration": 0.35},

			{"type": "character_hide", "id": "shopkeeper", "duration": 0.2},

			{"type": "set_bg", "key": "default"},

			{"type": "fade_in", "duration": 0.35},

			{
				"type": "character_show",
				"id": "shopkeeper",
				"slot": "right",
				"expression": "happy",
				"from": Vector2(1600, 620),
				"duration": 0.6
			}
		],
		"text": [
			{"character": "Shopkeeper", "text": "WAIT! Miss Reimu!"},
			{"character": "Reimu", "text": "Huh? You followed me out here?"},
			{"character": "Shopkeeper", "text": "I actually have a request for you."},
			{"character": "Shopkeeper", "text": "Monsters have been appearing near the shrine."},
			{"character": "Shopkeeper", "text": "Could you investigate for me?"},
			{"character": "Reimu", "text": "…Sounds troublesome."},
			{"character": "Reimu", "text": "Alright. I'll handle it."}
		],
		"next_event": 7
	},
	13: {
		"name": "Enemy",
		"actions": [
			{"type": "fade_out", "duration": 0.35},

			{"type": "character_hide", "id": "shopkeeper", "duration": 0.2},

			{"type": "set_bg", "key": "default"},

			{"type": "fade_in", "duration": 0.35},
			
			{
				"type": "character_show",
				"id": "rumia",
				"slot": "right",
				"expression": "neutral",
				"from": Vector2(1600, 420),
				"duration": 0.6
			},
		{
			"type": "character_expression",
			"id": "reimu",
			"expression": "sad"
		},
		{
			"type": "character_shake",
			"id": "reimu",
			"duration": 0.4,
			"magnitude": 8
		}
	],
	"text": [
		{"character": "Reimu", "text": "...Okay."},
		{"character": "Reimu", "text": "That definitely wasn't here before."},
		{"character": "Rumia", "text": "You're Reimu yes?"},
		{"character": "Reimu", "text": "I think so"},
		{"character": "Rumia", "text": "I knew it!"},
	],
	"choices": [
		{"text": "ENTER Battle", "next_event": 14},
		{"text": "Retreat carefully", "next_event": 15}
	]
},
}


var _tween: Tween
var is_typing := false
var is_transitioning: bool = false
var _is_running_actions: bool = false


# ------------------------
# Ready
# ------------------------
func _ready() -> void:
	
	
	if Globals.debug_f6:
		Globals.parameters = {
			"eventID": 0
		}
		
	Globals.play_music(preload("res://aud/mus/RapTest.ogg"), 0.5)
		
	Fade.fade_out(1.0, Color.WHITE)
	
	
	VN.line_changed.connect(_on_vn_line_changed)
	VN.choices_changed.connect(_on_vn_choices_changed)
	VN.finished.connect(_on_vn_finished)
	VN.actions_requested.connect(_on_vn_actions_requested)

	character_manager.register_characters(character_defs)
	VN.start(events, Globals.parameters["eventID"])

	process_mode = Node.PROCESS_MODE_ALWAYS

	if pause_button:
		pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	if save_button:
		save_button.process_mode = Node.PROCESS_MODE_ALWAYS

	if bg_fade:
		bg_fade.visible = true
		bg_fade.z_index = 9999
		bg_fade.color = Color(0, 0, 0, 0.0)
		_update_fade_mouse_filter()

	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

	if sword_sprite:
		sword_sprite.visible = false
		sword_sprite.scale = Vector2(0, 0)

	if bg and bg_textures.has("default"):
		bg.texture = bg_textures["default"]
		current_bg_key = "default"


# ------------------------
# Input
# ------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		return

	if get_tree().paused:
		return

	if choices_container.visible:
		return

	var proceed := event.is_action_pressed("ui_accept")

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		proceed = true

	if proceed:
		if is_typing:
			finish_line()
		else:
			VN.next_line()


# ------------------------
# Typewriter
# ------------------------
func start_typewriter() -> void:
	if _tween:
		_tween.kill()

	is_typing = true
	text_label.visible_characters = 0

	var total_chars := text_label.get_total_character_count()
	_tween = _new_game_tween()
	_tween.finished.connect(_on_tween_finished)
	_tween.tween_property(text_label, "visible_characters", total_chars, total_chars / display_speed)

func finish_line() -> void:
	if _tween:
		_tween.kill()
	text_label.visible_characters = -1
	is_typing = false

func _on_tween_finished() -> void:
	is_typing = false


# ------------------------
# Choices
# ------------------------
func show_choices(choices: Array) -> void:
	choices_container.visible = true

	for button in choices_container.get_children():
		button.queue_free()

	for choice in choices:
		var button := choice_button_scene.instantiate() as Button
		button.text = choice["text"]
		button.pressed.connect(_on_choice_selected.bind(choice["next_event"]))
		choices_container.add_child(button)

func _on_choice_selected(next_event: int) -> void:
	choices_container.visible = false
	VN.choose(next_event)


# ------------------------
# Pause / Save
# ------------------------
func _toggle_pause() -> void:
	var paused := !get_tree().paused
	get_tree().paused = paused

	if _tween:
		if paused:
			_tween.pause()
		else:
			_tween.play()

	if bg_fade:
		bg_fade.visible = true
		if paused:
			bg_fade.color = Color(0, 0, 0, pause_dim_alpha)
		else:
			if not is_transitioning:
				bg_fade.color = Color(0, 0, 0, 0.0)

	_update_fade_mouse_filter()
	_update_pause_button_text()

func _on_pause_pressed() -> void:
	_toggle_pause()

func _update_pause_button_text() -> void:
	if pause_button:
		pause_button.text = "Resume" if get_tree().paused else "Pause"


# ------------------------
# Fade helpers
# ------------------------
func fade_to_black(duration: float = 0.35) -> Tween:
	if bg_fade == null:
		return null

	is_transitioning = true
	bg_fade.visible = true
	bg_fade.color = Color(0, 0, 0, 0.0)
	_update_fade_mouse_filter()

	var t: Tween = _new_game_tween()
	t.tween_property(bg_fade, "color:a", 1.0, duration)
	t.finished.connect(func():
		is_transitioning = false
		_update_fade_mouse_filter()
	)
	return t

func fade_from_black(duration: float = 0.35) -> Tween:
	if bg_fade == null:
		return null

	is_transitioning = true
	bg_fade.visible = true
	_update_fade_mouse_filter()

	var t: Tween = _new_game_tween()
	t.tween_property(bg_fade, "color:a", 0.0, duration)
	t.finished.connect(func():
		is_transitioning = false
		if get_tree().paused:
			bg_fade.color = Color(0, 0, 0, pause_dim_alpha)
		else:
			bg_fade.color = Color(0, 0, 0, 0.0)
		_update_fade_mouse_filter()
	)
	return t

func _update_fade_mouse_filter() -> void:
	if bg_fade == null:
		return

	var a := bg_fade.color.a
	if a > 0.01:
		bg_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		bg_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


# ------------------------
# Tween helper
# ------------------------
func _new_game_tween() -> Tween:
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	return t


# ------------------------
# Dialogue callbacks
# ------------------------
func _on_vn_line_changed(character: String, text: String) -> void:
	choices_container.visible = false
	name_label.text = character
	text_label.text = text

	if character != "":
		_focus_speaker(character)

	start_typewriter()

func _on_vn_choices_changed(choices: Array) -> void:
	show_choices(choices)
	name_label.text = ""
	text_label.text = "Choose an option:"

func _on_vn_finished() -> void:
	name_label.text = ""
	text_label.text = "END OF DIALOGUE"

func _on_vn_actions_requested(actions: Array) -> void:
	if _is_running_actions:
		return
	_is_running_actions = true
	await run_actions(actions)
	_is_running_actions = false


# ------------------------
# Speaker focus
# ------------------------
func _focus_speaker(character_name: String) -> void:
	var speaker_id: String = character_name.to_lower()

	for id in character_manager.active_characters.keys():
		var ch: CharacterPortrait = character_manager.active_characters[id]
		if ch == null:
			continue

		var tw: Tween = _new_game_tween()

		if id == speaker_id:
			tw.tween_property(ch, "modulate", Color(1, 1, 1, 1), 0.15)
			tw.parallel().tween_property(ch, "scale", Vector2(1.0, 1.0), 0.15)
		else:
			tw.tween_property(ch, "modulate", Color(0.65, 0.65, 0.65, 1), 0.15)
			tw.parallel().tween_property(ch, "scale", Vector2(0.96, 0.96), 0.15)


# ------------------------
# Actions
# ------------------------
func run_actions(actions: Array) -> void:
	for a in actions:
		if typeof(a) != TYPE_DICTIONARY:
			continue

		if a.has("if_bg") and String(a["if_bg"]) != current_bg_key:
			continue

		var t := String(a.get("type", ""))

		match t:
			"character_show":
				await _action_character_show(a)

			"character_move":
				await _action_character_move(a)

			"character_expression":
				_action_character_expression(a)

			"character_hide":
				await _action_character_hide(a)

			"character_shake":
				await _action_character_shake(a)

			"fade_out":
				var dur_out := float(a.get("duration", 0.35))
				var tw_out: Tween = fade_to_black(dur_out)
				if tw_out:
					await tw_out.finished

			"fade_in":
				var dur_in := float(a.get("duration", 0.35))
				var tw_in: Tween = fade_from_black(dur_in)
				if tw_in:
					await tw_in.finished

			"set_bg":
				var key := String(a.get("key", "default"))
				if bg and bg_textures.has(key):
					bg.texture = bg_textures[key]
					current_bg_key = key

			"sword_show_anim":
				if sword_sprite and not sword_sprite.visible:
					sword_sprite.visible = true
					sword_sprite.position = Vector2(400, 200)
					sword_sprite.scale = Vector2(0, 0)
					sword_sprite.rotation_degrees = 0
					var tw_show: Tween = _new_game_tween()
					tw_show.tween_property(sword_sprite, "scale", Vector2(0.2, 0.2), 0.5)
					tw_show.tween_property(sword_sprite, "position", Vector2(400, 900), 0.5)
					tw_show.tween_property(sword_sprite, "rotation_degrees", 90, 0.5)
					await tw_show.finished

			"sword_hide":
				if sword_sprite and sword_sprite.visible:
					var dur_hide := float(a.get("duration", 0.4))
					var tw_hide: Tween = _new_game_tween()
					tw_hide.tween_property(sword_sprite, "scale", Vector2(0, 0), dur_hide)
					await tw_hide.finished
					sword_sprite.visible = false
					
			"go_to_exploration":
				var type = String(a.get("type_name", "world1"))
				var level = int(a.get("level", 0))
				var x = int(a.get("x", 0))
				var y = int(a.get("y", 0))

				goToExploration(type, level, x, y)

			_:
				pass


func _action_character_show(data: Dictionary) -> void:
	var id: String = String(data.get("id", ""))
	if id.is_empty():
		return

	var slot: String = String(data.get("slot", "left"))
	var expr: String = String(data.get("expression", ""))
	var duration: float = float(data.get("duration", 0.35))

	var ch: CharacterPortrait = character_manager.spawn_character(id, slot)
	if ch == null:
		return

	if not expr.is_empty():
		character_manager.set_expression(id, expr)

	if data.has("from"):
		var from_pos: Vector2 = data.get("from", ch.position)
		ch.position = from_pos

		var tw: Tween = _new_game_tween()
		tw.tween_property(ch, "position", character_manager.get_slot_position(slot), duration)
		await tw.finished
	else:
		ch.position = character_manager.get_slot_position(slot)

func _action_character_move(data: Dictionary) -> void:
	var id: String = String(data.get("id", ""))
	var slot: String = String(data.get("slot", "left"))
	var duration: float = float(data.get("duration", 0.35))

	var ch: CharacterPortrait = character_manager.get_character_node(id)
	if ch == null:
		return

	var target: Vector2 = character_manager.get_slot_position(slot)

	var tw: Tween = _new_game_tween()
	tw.tween_property(ch, "position", target, duration)
	await tw.finished

	character_manager.character_slots[id] = slot

func _action_character_expression(data: Dictionary) -> void:
	var id: String = String(data.get("id", ""))
	var expr: String = String(data.get("expression", ""))

	if id.is_empty() or expr.is_empty():
		return

	character_manager.set_expression(id, expr)

func _action_character_hide(data: Dictionary) -> void:
	var id: String = String(data.get("id", ""))
	var duration: float = float(data.get("duration", 0.35))

	var ch: CharacterPortrait = character_manager.get_character_node(id)
	if ch == null:
		return

	var current_slot: String = String(character_manager.character_slots.get(id, "left"))
	var offscreen: Vector2 = Vector2(-300, ch.position.y)

	if current_slot == "right":
		var screen_w: float = get_viewport_rect().size.x
		offscreen = Vector2(screen_w + 300, ch.position.y)

	var tw: Tween = _new_game_tween()
	tw.tween_property(ch, "position", offscreen, duration)
	await tw.finished

	character_manager.remove_character(id)

func _action_character_shake(data: Dictionary) -> void:
	var id: String = String(data.get("id", ""))
	var duration: float = float(data.get("duration", 0.5))
	var magnitude: float = float(data.get("magnitude", 10.0))

	var ch: CharacterPortrait = character_manager.get_character_node(id)
	if ch == null:
		return

	var original_pos: Vector2 = ch.position
	var tw: Tween = _new_game_tween()

	var steps: int = 10
	for i in range(steps):
		var offset: Vector2 = Vector2(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude)
		)
		tw.tween_property(ch, "position", original_pos + offset, duration / steps)

	tw.tween_property(ch, "position", original_pos, duration / steps)
	await tw.finished


## Default expected parameters would be
## "world1", 0, 0, 0
func goToExploration(type, level, x, y):
	move_out_parameters = [type, level, x, y]
	$tmrTransition.start()
	Fade.fade_out($tmrTransition.wait_time)

func _on_tmr_transition_timeout() -> void:
	
	Globals.startExploration(move_out_parameters[0], move_out_parameters[1],
	move_out_parameters[2], move_out_parameters[3])
