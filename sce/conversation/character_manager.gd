extends Node2D
class_name CharacterManager

@export var character_portrait_scene: PackedScene

var slots := {
	"left": Vector2(650, 520),
	"center": Vector2(640, 620),
	"right": Vector2(5530, 620)
}

var character_defs := {}
var active_characters := {}
var character_slots := {}

func register_character(id: String, def_data: Dictionary) -> void:
	character_defs[id] = def_data

func register_characters(defs: Dictionary) -> void:
	for id in defs.keys():
		character_defs[id] = defs[id]

func has_character(id: String) -> bool:
	return active_characters.has(id)

func get_character_node(id: String) -> CharacterPortrait:
	return active_characters.get(id, null)

func get_slot_position(slot: String) -> Vector2:
	return slots.get(slot, Vector2.ZERO)

func spawn_character(id: String, slot: String = "left") -> CharacterPortrait:
	if not character_defs.has(id):
		push_error("CharacterManager: missing definition for '%s'" % id)
		return null

	if active_characters.has(id):
		return active_characters[id]

	if character_portrait_scene == null:
		push_error("CharacterManager: character_portrait_scene is not assigned.")
		return null

	var def_data: Dictionary = character_defs[id]
	var portrait: CharacterPortrait = character_portrait_scene.instantiate()
	add_child(portrait)

	portrait.character_id = id
	portrait.position = get_slot_position(slot)

	var body_tex: Texture2D = def_data.get("body", null)
	var default_expr: String = def_data.get("default_expression", "neutral")
	var exprs: Dictionary = def_data.get("expressions", {})

	portrait.set_body(body_tex)

	if exprs.has(default_expr):
		portrait.set_expression(default_expr, exprs[default_expr])

	active_characters[id] = portrait
	character_slots[id] = slot
	return portrait

func set_expression(id: String, expr_name: String) -> void:
	if not active_characters.has(id):
		return
	if not character_defs.has(id):
		return

	var def_data: Dictionary = character_defs[id]
	var exprs: Dictionary = def_data.get("expressions", {})

	if exprs.has(expr_name):
		active_characters[id].set_expression(expr_name, exprs[expr_name])

func move_character_instant(id: String, slot: String) -> void:
	if not active_characters.has(id):
		return

	active_characters[id].position = get_slot_position(slot)
	character_slots[id] = slot

func remove_character(id: String) -> void:
	if not active_characters.has(id):
		return

	active_characters[id].queue_free()
	active_characters.erase(id)
	character_slots.erase(id)

func clear_all() -> void:
	for id in active_characters.keys():
		var portrait: CharacterPortrait = active_characters[id]
		if portrait:
			portrait.queue_free()

	active_characters.clear()
	character_slots.clear()
