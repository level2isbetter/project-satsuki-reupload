class_name ATBBar extends TextureProgressBar

signal filled()

const SPEED_BASE: float = 0.25

@onready var _anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_anim.play("RESET")
	value = randf_range(min_value, max_value * 0.75)

func reset() -> void:
	value = min_value
	set_process(true)

func _process(delta: float) -> void:
	value += SPEED_BASE
	
	if is_equal_approx(value, max_value):
		_anim.play("highlight")
		set_process(false)
		filled.emit()

func _on_value_changed(value: float) -> void:
	pass
