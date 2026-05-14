extends Node
class_name InventorySystem

const MAX_SLOTS: int = 50
# these are all the signals I can think of, add more if necessary
signal itemAdded(item: Dictionary, slotIndex: int)
signal itemRemoved(item: Dictionary, slotIndex: int)
signal itemUsed(item: Dictionary, slotIndex: int)
signal inventoryFull()
var slots: Array[Dictionary] = []

func _ready() -> void:
	# Initialize empty slots
	for i in range(MAX_SLOTS):
		slots.append({})

func addItem(itemData: Dictionary) -> bool:
	# most of this is testing, replace and expand as needed
	if itemData.get("stackable", false):
		var stackedSlot: int = findStackableSlot(itemData)
		if stackedSlot != -1:
			slots[stackedSlot]["quantity"] += itemData.get("quantity", 1)
			itemAdded.emit(itemData, stackedSlot)
			print("Stacked %s (now %d)" % [itemData["name"], slots[stackedSlot]["quantity"]])
			return true
	var emptySlot: int = findEmptySlot()
	if emptySlot != -1:
		var newItem: Dictionary = itemData.duplicate()
		if not newItem.has("quantity"):
			newItem["quantity"] = 1
		slots[emptySlot] = newItem
		itemAdded.emit(newItem, emptySlot)
		print("Added %s to slot %d" % [newItem["name"], emptySlot])
		return true
	inventoryFull.emit()
	print("Inventory full! Cannot add %s" % itemData["name"])
	return false

# if an item is removed, have it go through this function. 
#quantity will be reduced by 1 by default, but that can be changed(?) if needed

func removeItem(slotIndex: int, quantity: int = 1) -> bool:
	if slotIndex < 0 or slotIndex >= MAX_SLOTS:
		return false
	
	if slots[slotIndex].is_empty():
		return false
	
	var item: Dictionary = slots[slotIndex]
	item["quantity"] -= quantity
	
	if item["quantity"] <= 0:
		var removedItem: Dictionary = item.duplicate()
		slots[slotIndex] = {}
		itemRemoved.emit(removedItem, slotIndex)
		print("Removed %s from slot %d" % [removedItem["name"], slotIndex])
	else:
		print("Removed %d %s (% d remaining)" % [quantity, item["name"], item["quantity"]])
	return true

# if an item can be used, have it go through this function
func useItem(slotIndex: int) -> void:
	if slotIndex < 0 or slotIndex >= MAX_SLOTS:
		return
	if slots[slotIndex].is_empty():
		return
	
	var item: Dictionary = slots[slotIndex]
	print("Used %s" % item["name"])
	itemUsed.emit(item, slotIndex)
	# destroy consumable after use
	if item.get("consumable", false):
		removeItem(slotIndex, 1)

func findEmptySlot() -> int:
	for i in range(MAX_SLOTS):
		if slots[i].is_empty():
			return i
	return -1

func findStackableSlot(itemData: Dictionary) -> int:
	for i in range(MAX_SLOTS):
		var slot: Dictionary = slots[i]
		if not slot.is_empty():
			if slot["id"] == itemData["id"] and slot.get("stackable", false):
				var maxStack: int = slot.get("maxStack", 99)
				if slot["quantity"] < maxStack:
					return i
	return -1

func hasItem(itemId: String) -> bool:
	for slot in slots:
		if not slot.is_empty() and slot["id"] == itemId:
			return true
	return false

func getItemCount(itemId: String) -> int:
	var count: int = 0
	for slot in slots:
		if not slot.is_empty() and slot["id"] == itemId:
			count += slot.get("quantity", 1)
	return count

func getSlot(index: int) -> Dictionary:
	if index >= 0 and index < MAX_SLOTS:
		return slots[index]
	return {}

func isEmpty() -> bool:
	for slot in slots:
		if not slot.is_empty():
			return false
	return true

func clear() -> void:
	for i in range(MAX_SLOTS):
		slots[i] = {}
	print("Inventory cleared")
