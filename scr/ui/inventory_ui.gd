extends Control

# central code for inventory UI that Displays 
# inventory grid, manages UI interactions, etc...
# note: a lot of functionality here is very boiler plate.
# adjust as needed.

@onready var inventoryGrid: GridContainer = $Panel/MarginContainer/VBoxContainer/InventoryGrid
@onready var itemNameLabel: Label = $Panel/MarginContainer/VBoxContainer/ItemInfo/ItemName
@onready var itemDescLabel: Label = $Panel/MarginContainer/VBoxContainer/ItemInfo/ItemDesc

var slots: Array[Control] = []
var selectedSlotIndex: int = -1

func _ready() -> void:
	hide()
	createSlots()
	
	# connection to global inventory
	if Globals.inventory != null:
		Globals.inventory.itemAdded.connect(_onItemAdded)
		Globals.inventory.itemRemoved.connect(_onItemRemoved)
		Globals.inventory.itemUsed.connect(_onItemUsed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		toggleInventory()

func toggleInventory() -> void:
	visible = not visible
	if visible:
		refreshAll()

func createSlots() -> void:
	for child in inventoryGrid.get_children():
		child.queue_free()
	slots.clear()
	
	# create 50 slots, can be more/less, but this
	# UI is optimal for 50. Change UI accordingly if you do.
	for i in range(50):
		var slot: Control = createSlot(i)
		inventoryGrid.add_child(slot)
		slots.append(slot)

func createSlot(index: int) -> Control:
	var slot: Panel = Panel.new()
	slot.custom_minimum_size = Vector2(64, 64)
	slot.name = "Slot%d" % index
	
	# background stylesheet. Designed for a dark, 
	#slightly transparent look. Probably too boring for Alex's
	# vision, so I recommend changing it later.
	var styleBox: StyleBoxFlat = StyleBoxFlat.new()
	styleBox.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	styleBox.set_border_width_all(2)
	styleBox.border_color = Color(0.4, 0.4, 0.4)
	slot.add_theme_stylebox_override("panel", styleBox)
	
	# populates with icons
	var icon: TextureRect = TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	slot.add_child(icon)
	var qtyLabel: Label = Label.new()
	qtyLabel.name = "Quantity"
	qtyLabel.text = ""
	qtyLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	qtyLabel.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	qtyLabel.anchor_right = 1.0
	qtyLabel.anchor_bottom = 1.0
	qtyLabel.add_theme_color_override("font_color", Color.WHITE)
	qtyLabel.add_theme_color_override("font_outline_color", Color.BLACK)
	qtyLabel.add_theme_constant_override("outline_size", 4)
	slot.add_child(qtyLabel)
	var button: Button = Button.new()
	button.flat = true
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.pressed.connect(_onSlotClicked.bind(index))
	slot.add_child(button)
	
	return slot

func refreshAll() -> void:
	if Globals.inventory == null:
		return
	for i in range(50):
		refreshSlot(i)

func refreshSlot(index: int) -> void:
	if index < 0 or index >= slots.size():
		return
	var slot: Panel = slots[index] as Panel
	if not slot:
		return
	var itemData: Dictionary = Globals.inventory.getSlot(index)
	var icon: TextureRect = slot.get_node("Icon") as TextureRect
	var qtyLabel: Label = slot.get_node("Quantity") as Label
	
	if itemData.is_empty():
		icon.texture = null
		qtyLabel.text = ""
	else:
		if itemData.has("icon"):
			var texture: Texture2D = load(itemData["icon"]) as Texture2D
			if texture:
				icon.texture = texture
		
		var qty: int = itemData.get("quantity", 1)
		if qty > 1:
			qtyLabel.text = str(qty)
		else:
			qtyLabel.text = ""

func _onSlotClicked(index: int) -> void:
	selectedSlotIndex = index
	showItemInfo(index)

func showItemInfo(index: int) -> void:
	var itemData: Dictionary = Globals.inventory.getSlot(index)
	if itemData.is_empty():
		itemNameLabel.text = ""
		itemDescLabel.text = ""
	else:
		itemNameLabel.text = itemData.get("name", "Unknown")
		itemDescLabel.text = itemData.get("description", "")

func _onItemAdded(_item: Dictionary, slotIndex: int) -> void:
	if visible:
		refreshSlot(slotIndex)

func _onItemRemoved(_item: Dictionary, slotIndex: int) -> void:
	if visible:
		refreshSlot(slotIndex)

func _onItemUsed(item: Dictionary, slotIndex: int) -> void:
	print("Used %s" % item["name"])
	if item.get("type") == "food":
		var healAmount: int = item.get("healAmount", 0)
		Globals.playerHealth = min(Globals.playerHealth + healAmount, Globals.playerMaxHealth)
		print("Healed %d HP" % healAmount)
	if visible:
		refreshSlot(slotIndex)
