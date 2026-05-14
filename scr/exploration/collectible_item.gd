extends Area2D
class_name CollectibleItem

@export var itemId: String = "yen"
@export var quantity: int = 1
#change if you want to collect using the interact key
@export var autoCollect: bool = true
@export var floatAnimation: bool = true
@export var floatHeight: float = 8.0
@export var floatSpeed: float = 2.0
#can optionally make items rotate, but it looks weird with test assets
# so default is 0. Adjust the individual item in the Godot Inspector if you want
# it to rotate
@export var rotateSpeed: float = 0.0

signal collected(item: Dictionary)
var basePosition: Vector2
var timeElapsed: float = 0.0
var itemData: Dictionary

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

# database for handling items. If you want to add new items, add them here and make sure to 
# give them a unique ID. If you do, also add the same entry to item_database.
const ITEM_DATA: Dictionary = {
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
		"icon": "res://img/items/figure.png",
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

func _ready() -> void:
	# set collision for player detection
	collision_layer = 2
	collision_mask = 1
	
	# connect signals
	body_entered.connect(_onBodyEntered)
	
	# load item data from built-in database
	if ITEM_DATA.has(itemId):
		itemData = ITEM_DATA[itemId].duplicate()
		itemData["quantity"] = quantity
	else:
		push_error("Invalid item ID: %s" % itemId)
		queue_free()
		return
	
	# Load sprite if available - BE SURE TO ADD IMAGES FOR NEW ITEMS IN
	# IMG/ITEMS
	if sprite and itemData.has("icon"):
		var texture: Texture2D = load(itemData["icon"]) as Texture2D
		if texture:
			sprite.texture = texture
		else:
			createFallbackSprite()
	
	basePosition = position
	print("Collectible item spawned: %s x%d" % [itemData["name"], quantity])

func _process(delta: float) -> void:
	if not floatAnimation:
		return
	
	timeElapsed += delta
	
	# floating animation. Felt necessary to help stand out, otherwise,
	# just set to zero in Inspector
	position.y = basePosition.y + sin(timeElapsed * floatSpeed) * floatHeight
	#same but for rotation
	if sprite and rotateSpeed > 0:
		sprite.rotation += rotateSpeed * delta

func _onBodyEntered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if autoCollect:
			collect(body)

func collect(_collector: Node2D) -> void:
	# add to inventory via Global singleton
	if Globals.inventory != null:
		var success: bool = Globals.inventory.addItem(itemData)
		if success:
			Globals.play_sfx(preload("res://aud/sfx/exploration/grab.ogg"))
			collected.emit(itemData)
			print("Player collected: %s x%d" % [itemData["name"], quantity])
			queue_free()
		else:
			print("Inventory full! Cannot collect %s" % itemData["name"])
			Globals.play_sfx(preload("res://aud/sfx/ui/menu/warning.ogg"))
	else:
		push_warning("No global inventory system found!")
		queue_free()


# fallbacks to identify items by type if no image exists - please fix
# ASAP if you encounter this, ESPECIALLY if it's a gray square
func createFallbackSprite() -> void:
	if not sprite:
		return
	var color: Color = Color.WHITE
	match itemData.get("type", ""):
		"currency":
			color = Color.GOLD
		"food":
			color = Color.GREEN
		"weapon":
			color = Color.RED
		_:
			color = Color.GRAY
	
	var img: Image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(color)
	sprite.texture = ImageTexture.create_from_image(img)
