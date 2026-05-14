class_name PauseMenu extends NinePatchRect

signal opened
signal closed
signal resume_requested
signal exit_requested

@onready var _settings_menu: VBoxContainer = $SettingsMenu
@onready var _menu_display: TextureRect = $MenuDisplay
@onready var _volume_slider: HSlider = $SettingsMenu/HBoxContainer/VolumeSlider
@onready var _back_button: Button = $SettingsMenu/BackButton

const MENU_TEXTURE: Texture2D = preload("res://img/battle/ui/menu.png")
const MENU_ITEMS_TEXTURE: Texture2D = preload("res://img/battle/ui/menu_items.png")
const MENU_SELECT_TEXTURES: Array[Texture2D] = [
	preload("res://img/battle/ui/menu_select_0.png"),
	preload("res://img/battle/ui/menu_select_1.png"),
	preload("res://img/battle/ui/menu_select_2.png")
]
const MENU_PRESS_TEXTURES: Array[Texture2D] = [
	preload("res://img/battle/ui/menu_press_0.png"),
	preload("res://img/battle/ui/menu_press_1.png"),
	preload("res://img/battle/ui/menu_press_2.png")
]

enum MenuMode {
	MAIN,
	SETTINGS
}

var _menu_mode: MenuMode = MenuMode.MAIN
var _menu_select_num: int = 0

func _ready() -> void:
	if _back_button:
		_back_button.pressed.connect(_on_back_button_pressed)
	
	# connect volume slider
	if _volume_slider:
		_volume_slider.value_changed.connect(_on_volume_changed)
		# set initial range
		_volume_slider.min_value = 0
		_volume_slider.max_value = 100
		_volume_slider.value = 75  # default volume
		_volume_slider.step = 1
	
	_show_main_menu()
	hide()

func open() -> void:
	show()
	_show_main_menu()
	opened.emit()

func close() -> void:
	hide()
	closed.emit()

func _show_main_menu() -> void:
	_menu_mode = MenuMode.MAIN
	_menu_select_num = 0
	if _menu_display:
		_menu_display.texture = MENU_SELECT_TEXTURES[_menu_select_num]
	if _back_button:
		_back_button.release_focus()
	if _volume_slider:
		_volume_slider.release_focus()
	_settings_menu.hide()

func _show_settings() -> void:
	_menu_mode = MenuMode.SETTINGS
	if _menu_display:
		_menu_display.texture = MENU_ITEMS_TEXTURE
	_settings_menu.show()
	if _volume_slider:
		_volume_slider.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if _menu_mode == MenuMode.MAIN:
		_handle_main_menu_input(event)
	else:
		_handle_settings_menu_input(event)

func _handle_main_menu_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_cycle_main_selection(-1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_down"):
		_cycle_main_selection(1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_accept"):
		_activate_main_selection()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()

func _handle_settings_menu_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_return_to_main_menu()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		_toggle_settings_focus()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_accept") and _back_button and _back_button.has_focus():
		_return_to_main_menu()
		get_viewport().set_input_as_handled()

func _cycle_main_selection(direction: int) -> void:
	_menu_select_num = posmod(_menu_select_num + direction, MENU_SELECT_TEXTURES.size())
	if _menu_display:
		_menu_display.texture = MENU_SELECT_TEXTURES[_menu_select_num]

func _activate_main_selection() -> void:
	if _menu_display:
		_menu_display.texture = MENU_PRESS_TEXTURES[_menu_select_num]
	await get_tree().create_timer(0.08).timeout

	match _menu_select_num:
		0:
			resume_requested.emit()
		1:
			_show_settings()
		2:
			exit_requested.emit()

func _toggle_settings_focus() -> void:
	if _back_button and _back_button.has_focus():
		if _volume_slider:
			_volume_slider.grab_focus()
		return

	if _back_button:
		_back_button.grab_focus()

func _return_to_main_menu() -> void:
	_menu_mode = MenuMode.MAIN
	_menu_select_num = 1
	if _menu_display:
		_menu_display.texture = MENU_TEXTURE
		_menu_display.texture = MENU_SELECT_TEXTURES[_menu_select_num]
	_settings_menu.hide()

func _on_back_button_pressed() -> void:
	_return_to_main_menu()

func _on_volume_changed(value: float) -> void:
	print("Volume changed to: ", value)
