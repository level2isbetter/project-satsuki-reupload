class_name MenuCursor extends Sprite2D

const OFFSET: Vector2 = Vector2(150, 185)

var target: Node = null
var pulse_time := 0.0
const PULSE_SPEED := 1.75
const PULSE_AMOUNT := 0.03
const ROTATE_SPEED := 2.5

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if is_instance_valid(target):
		# spinning
		rotation += _delta * ROTATE_SPEED
		
		# offset
		global_position = target.global_position + OFFSET
		
		# pulse
		pulse_time += _delta * PULSE_SPEED
		var scale_factor = 0.145 + sin(pulse_time) * PULSE_AMOUNT
		scale = Vector2 (scale_factor, scale_factor)
	else:
		pass
