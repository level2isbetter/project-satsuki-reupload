class_name Enemies extends Node

var data: Dictionary = {
	"flame": {
		"name": "flame",
		"maxHP": 50,
		"atk": 92,
		"def": 3
	},
	"placeholder": {
		"name": "Placeholder",
		"maxHP": 30,
		"atk": 95,
		"def": 2
	}
}

func _init() -> void:
	pass

func create_enemy(enemy_type: String) -> BattleActor:
	if not data.has(enemy_type):
		enemy_type = "placeholder"
	
	var enemy_data = data[enemy_type]
	var enemy = BattleActor.new()
	enemy.name = enemy_data["name"]
	enemy.maxHP = enemy_data["maxHP"]
	enemy.hp = enemy_data["maxHP"]
	enemy.atk = enemy_data["atk"]
	enemy.def = enemy_data["def"]
	
	return enemy
