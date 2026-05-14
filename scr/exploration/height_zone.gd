extends Area2D
class_name HeightZone

# invisible zone that sets player's height level when entered
# probably something to be implemented later

# what height level is this platform?
@export var zoneHeight: int = 1 

func _ready() -> void:
	# set collision for player detection
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_onBodyEntered)
	body_exited.connect(_onBodyExited)
	print("HeightZone '%s' created at height %d" % [name, zoneHeight])

func _onBodyEntered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("setHeight"):
			body.setHeight(zoneHeight)
			print("Player entered height zone: %d" % zoneHeight)

func _onBodyExited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("setHeight"):
			# if true, then return to ground level
			body.setHeight(0)
			print("Player exited height zone")
