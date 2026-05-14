extends Node2D
class_name CharacterPortrait

@onready var body: Sprite2D = $Body
@onready var eyes: Sprite2D = $Eyes
@onready var mouth: Sprite2D = $Mouth

var character_id: String = ""
var current_expression: String = "neutral"

func set_body(tex: Texture2D) -> void:
	body.texture = tex

func set_expression(expr_name: String, expr_data: Dictionary) -> void:
	current_expression = expr_name
	eyes.texture = expr_data.get("eyes", null)
	mouth.texture = expr_data.get("mouth", null)

func set_visible_parts(body_tex: Texture2D, expr_name: String, expr_data: Dictionary) -> void:
	set_body(body_tex)
	set_expression(expr_name, expr_data)
