extends Node

# a list of all items I made for testing.
#obviously, add more with the below formatting.
const ITEMS: Dictionary = {
	"yen": {
		"id": "yen",
		"name": "One Yen",
		"description": "How did yen get to Gensokyo?",
		"type": "currency",
		"icon": "res://img/items/yen.png",
		"stackable": true,
		"maxStack": 999,
		"consumable": false,
		"value": 1
	},
	"figure": {
		"id": "figure",
		"name": "Mysterious Figure",
		"description": "An extra-ordinary figure of a witch.",
		"type": "misc",
		"icon": "res://img/items/figure.jpg",
		"stackable": true,
		"maxStack": 9,
		"consumable": false,
		"value": 10
	},
	"food_bread": {
		"id": "food_bread",
		"name": "Bread",
		"description": "Restores 20 HP. Yummers.",
		"type": "food",
		"icon": "res://img/items/bread.png",
		"stackable": true,
		"maxStack": 20,
		"consumable": true,
		"healAmount": 20,
		"value": 5
	},
	"food_apple": {
		"id": "food_apple",
		"name": "Apple",
		"description": "Restores 10 HP. Yummers.",
		"type": "food",
		"icon": "res://img/items/apple.png",
		"stackable": true,
		"maxStack": 20,
		"consumable": true,
		"healAmount": 10,
		"value": 3
	},
	"weapon_sword": {
		"id": "weapon_sword",
		"name": "Iron Sword",
		"description": "The things that can't be cut by this sword are next to none.",
		"type": "weapon",
		"icon": "res://img/items/sword.png",
		"stackable": false,
		"consumable": false,
		"equipSlot": "weapon",
		"attackBonus": 5,
		"value": 50
	},
	"weapon_gohei": {
		"id": "weapon_gohei",
		"name": "Wooden Gohei",
		"description": "A magic gohei O_O",
		"type": "weapon",
		"icon": "res://img/items/gohei.png",
		"stackable": false,
		"consumable": false,
		"equipSlot": "weapon",
		"magicBonus": 3,
		"value": 40
	}
}


static func getItem(itemId: String) -> Dictionary:
	if ITEMS.has(itemId):
		return ITEMS[itemId].duplicate()
	push_warning("Item '%s' not found in database!" % itemId)
	return {}

static func createItem(itemId: String, quantity: int = 1) -> Dictionary:
	var item: Dictionary = getItem(itemId)
	if not item.is_empty():
		item["quantity"] = quantity
	return item

static func getAllItems() -> Dictionary:
	return ITEMS
