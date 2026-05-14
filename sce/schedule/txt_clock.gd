extends TextureRect

var rotating := false
var last_vector := Vector2.ZERO
var angular_velocity := 0.0
var deceleration := 3.0
var sensitivity := 1.0

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				rotating = true
				
				angular_velocity *= 0.1

				last_vector = _vector_from_pivot(event.global_position)
			else:
				rotating = false

	if event is InputEventMouseMotion and rotating:
		var v1 = last_vector
		var v2 = _vector_from_pivot(event.global_position)
		
		if v1.length() > 0.001 and v2.length() > 0.001:
			var delta_angle = _normalize_angle(v1.angle_to(v2))

			rotation += delta_angle * sensitivity

			angular_velocity = delta_angle / get_process_delta_time()
			
		last_vector = v2


func _process(delta):
	if not rotating:
		rotation += angular_velocity * delta
		angular_velocity = move_toward(angular_velocity, 0.0, deceleration * delta)
		
		$sfxTick.play()
		if angular_velocity != 0.0:
			pass
		else:
			$sfxTick.stop()
		

func _vector_from_pivot(mouse_global_pos: Vector2) -> Vector2:
	var pivot = global_position + pivot_offset
	return mouse_global_pos - pivot


func _normalize_angle(a: float) -> float:
	return fmod(a + PI, TAU) - PI
