class_name BattleSpells extends RefCounted

const SPELLS: Dictionary = {
	"FIRE": {
		"name": "Fire",
		"cost": 7,
		"damage": 60
	},
	"ICE": {
		"name": "Ice",
		"cost": 3,
		"damage": 22
	}
}

static func get_spell(spell_id: String) -> Dictionary:
	return SPELLS.get(spell_id, {})
