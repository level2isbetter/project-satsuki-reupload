class_name SpellMenuUI extends Control

signal spell_selected(spell_id)
signal cancelled

@onready var _spell_options: Menu = $SpellOptions
@onready var _spell_pointer: TextureRect = $Pointer

func _ready() -> void:
	if _spell_options:
		_spell_options.button_focused.connect(_on_spell_options_focused)
		_spell_options.button_pressed.connect(_on_spell_options_pressed)
	hide()

func open() -> void:
	show()
	if _spell_options:
		_spell_options.button_focus(0)

func close() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		cancelled.emit()
		var viewport := get_viewport()
		if viewport:
			viewport.set_input_as_handled()

func _on_spell_options_focused(button: BaseButton) -> void:
	if not _spell_pointer:
		return

	var local_y: float = button.global_position.y - global_position.y
	_spell_pointer.position = Vector2(_spell_pointer.position.x, local_y + (button.size.y - _spell_pointer.size.y) * 0.5)

func _on_spell_options_pressed(button: BaseButton) -> void:
	spell_selected.emit(button.name)
