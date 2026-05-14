extends Node

## Constants
const MAX_POINTS = 40000
const MAX_CRITICAL = 0.5
const BASE_VALUE = 100
const SAVE_PATH = "user://00.sav"

## Variables for calendar
var day = 15
var month = 7
var year = 1997

var music_player = AudioStreamPlayer2D
var sfx_player = AudioStreamPlayer2D
var sfx_player2 = AudioStreamPlayer2D

## Debug variables
var debug_f6 = false

var mute_music = false
var mute_sfx = false

## Imported from EXPLORATION ####
var playerHealth: int = 100
var playerMaxHealth: int = 100

# inventory. Nama, you'll need to keep track of this
# if item drops after battles are a thing
var inventory: InventorySystem

# these are from earlier iterations and need to stick around because
# of compatibility. Can be removed with elbow grease.
func addItem(itemName: String, itemValue: int, itemType: String) -> void:
	var itemData: Dictionary = {
		"id": itemName.to_lower().replace(" ", "_"),
		"name": itemName,
		"value": itemValue,
		"type": itemType,
		"stackable": true,
		"quantity": 1
	}
	inventory.addItem(itemData)

func hasItem(itemName: String) -> bool:
	var itemId: String = itemName.to_lower().replace(" ", "_")
	return inventory.hasItem(itemId)

func removeItem(itemName: String) -> void:
	var itemId: String = itemName.to_lower().replace(" ", "_")
	for i in range(inventory.slots.size()):
		var slot: Dictionary = inventory.slots[i]
		if not slot.is_empty() and slot["id"] == itemId:
			inventory.removeItem(i, 1)
			return

######################

## Object holder for schedule items
var itemSelection = {
	0: {
		
	},
	1: {
		
	},
	2: {
		
	},
	3: {
		
	}
}

## Save object
var save_info = {
	# none - Use save() function
}

## override variable for scene switches
var _test_tree_override = null

## Parameter object for bridge connections
var parameters = {
	# None
}

## Numeric to month conversion
var monthName = {
	0: {
		"name": "Jan",
		"name_full": "January"
	},
	1: {
		"name": "Feb",
		"name_full": "February"
	},
	2: {
		"name": "Mar",
		"name_full": "March"
	},
	3: {
		"name": "Apr",
		"name_full": "April"
	},
	4: {
		"name": "May",
		"name_full": "May"
	},
	5: {
		"name": "Jun",
		"name_full": "June"
	},
	6: {
		"name": "Jul",
		"name_full": "July"
	},
	7: {
		"name": "Aug",
		"name_full": "August"
	},
	8: {
		"name": "Sep",
		"name_full": "September"
	},
	9: {
		"name": "Oct",
		"name_full": "October"
	},
	10: {
		"name": "Nov",
		"name_full": "November"
	},
	11: {
		"name": "Dec",
		"name_full": "December"
	},
}

## Rank letter to value mapper
var rank = {
	0: {
		"name": "E",
		"level_up_modifier": 0.125
	},
	1: {
		"name": "D",
		"level_up_modifier": 0.25
	},
	2: {
		"name": "C",
		"level_up_modifier": 0.5
	},
	3: {
		"name": "B",
		"level_up_modifier": 1.0
	},
	4: {
		"name": "A",
		"level_up_modifier": 2.0
	},
	5: {
		"name": "S",
		"level_up_modifier": 4.0
	}
}

## Virtue objects
var virtue = {
	0: {
		"name": "Charity",
		"rank":  1,
		"level": 1,
		"value": 200,
		"level_progress": 50.0,
		"rank_progress": 0.0
	},
	1: {
		"name": "Chastity",
		"rank":  2,
		"level": 3,
		"value": 900,
		"level_progress": 80.0,
		"rank_progress": 0.0
	},
	2: {
		"name": "Diligence",
		"rank":  3,
		"level": 4,
		"value": 2000,
		"level_progress": 20.0,
		"rank_progress": 0.0
	},
	3: {
		"name": "Humility",
		"rank":  4,
		"level": 5,
		"value": 2400,
		"level_progress": 0.0,
		"rank_progress": 0.0
	},
	4: {
		"name": "Kindness",
		"rank":  4,
		"level": 5,
		"value": 2400,
		"level_progress": 10.0,
		"rank_progress": 0.0
	},
	5: {
		"name": "Patience",
		"rank":  3,
		"level": 3,
		"value": 900,
		"level_progress": 40.0,
		"rank_progress": 0.0
	},
	6: {
		"name": "Temperance",
		"rank":  2,
		"level": 2,
		"value": 400,
		"level_progress": 30.0,
		"rank_progress": 0.0
	}
}

func _ready():
	# Create audio players at runtime
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	sfx_player2 = AudioStreamPlayer.new()
	var path = get_tree().current_scene.scene_file_path
	
	print("======================================")
	if path == "res://sce/main.tscn":
		print("STARTING AT F5 - " + path)
	else:
		print("STARTING AT F6 - " + path)
		debug_f6 = true
	print("======================================")

	
	## For exploration
	inventory = InventorySystem.new()
	add_child(inventory)

	# Optional: music loops by default
	music_player.stream_paused = false

	add_child(music_player)
	add_child(sfx_player)
	add_child(sfx_player2)
	
	getSave()
	
func _process(delta):
	if Input.is_action_just_pressed("escape"):
		Globals.restart()
	
func play_music(stream: AudioStream, volume := 1.0, loop := true):
	
	if !mute_music:
		music_player.stream = stream
		music_player.volume_db = volume
		music_player.stream.loop = loop
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream, volume := 10.0, type:=0):
	
	if !mute_sfx:
		if type==0:
			sfx_player.stream = stream
			sfx_player.volume_db = volume
			sfx_player.play()
		else:
			sfx_player2.stream = stream
			sfx_player2.volume_db = volume
			sfx_player2.play()
	
func stop_sfx():
	sfx_player.stop()
	sfx_player2.stop()

## Schedule object items
var schedule_values = {
	0: {
		"name": "sleep",
		"info": "Sleep item info text",
		"image": load("res://img/icons/schedule/icon_test.png"),
		"para1_name": "Chastity",
		"para1": 80,
		"para2_name": "Temperance",
		"para2": 40,
		"para3_name": "Humility",
		"para3": 20
	},
	1: {
		"name": "interact",
		"info": "Interact item info text",
		"image": load("res://img/icons/schedule/icon_test.png"),
		"para1_name": "Chastity",
		"para1": 20,
		"para2_name": "Temperance",
		"para2": 30,
		"para3_name": "Humility",
		"para3": 70
	},
	2: {
		"name": "talk",
		"info": "Talk item info text",
		"image": load("res://img/icons/schedule/icon_test.png"),
		"para1_name": "Chastity",
		"para1": 10,
		"para2_name": "Temperance",
		"para2": 20,
		"para3_name": "Humility",
		"para3": 30
	},
	3: {
		"name": "overworld",
		"info": "Explore the world!",
		"image": load("res://img/icons/schedule/icon_test.png"),
		"para1_name": "Chastity",
		"para1": 10,
		"para2_name": "Temperance",
		"para2": 20,
		"para3_name": "Humility",
		"para3": 30
	},
	4: {
		"name": "null",
		"info": "Why are you still here?",
		"image": load("res://img/icons/schedule/icon_test.png"),
		"para1_name": "Chastity",
		"para1": 0,
		"para2_name": "Temperance",
		"para2": 0,
		"para3_name": "Humility",
		"para3": 0
	}
}

## Object value conversion from virtue to battle values
var battle_values = {
	0: {
		"name": "Attack",
		"value": int(virtue[0]["value"]/10)
	},
	1: {
		"name": "Critical",
		"value": value_remap_critical(virtue[0]["value"])
	},
	2: {
		"name": "Defense",
		"value": int(virtue[1]["value"]/10)
	},
	3: {
		"name": "Health",
		"value": int(virtue[6]["value"]/10)
	},
	4: {
		"name": "Magic",
		"value": int(virtue[4]["value"]/10)
	},
	5: {
		"name": "Meter",
		"value": value_remap_critical(virtue[0]["value"])
	},
	6: {
		"name": "Unused",
		"value": int(virtue[3]["value"]/10)
	}
}

## Conversation to critical percentage
func value_remap_critical(value):
	return (value / MAX_POINTS) * MAX_CRITICAL
	
## Levels up a virtue
func level_up(entry):
	
	if entry["level"] < 99:
		entry["level"] += 1
		entry["value"] += BASE_VALUE * rank[entry["rank"]]["level_up_modifier"]
		
## Levels down a virtue
func level_down(entry):
	if entry["level"] > 0:
		entry["level"] -= 1
		entry["value"] -= BASE_VALUE * rank[entry["rank"]]["level_up_modifier"]

## Ranks up a virtue
func rank_up(entry):
	if entry["rank"] < 5:
		entry["rank"] += 1
	
## Ranks down a virtue
func rank_down(entry):
	if entry["rank"] > 0:
		entry["rank"] -= 1

##Adjusts the progress of either rank or a level
##[br]
##[br][color=yellow]@param[/color]:
##[br][member current] - Derived from [member virtue[id]]
##[br][member selected] - [member int] value
##[br][member type] - Either [member "level"] or [member "rank"]
##[br]
##[br][color=yellow]@returns[/color]: [constant void]
func progress(current, selected, type):

	if type == "level":
		current["level_progress"] += selected
		
		if current["level_progress"] >= 100:
			current["level_progress"] -= 100
			level_up(current)
		elif current["level_progress"] < 0:
			current["level_progress"] -= 100
			level_down(current)
			
	elif type == "rank":
		current["rank_progress"] += selected
		
		if current["rank_progress"] >= 100:
			current["rank_progress"] -= 100
			rank_up(current)
		elif current["rank_progress"] < 0:
			current["rank_progress"] -= 100
			rank_down(current)


##Changes a day from either direction.
##[br]
##[br][color=yellow]@param[/color]:
##[br][member direction] - Either [member "forward"] or [member "backward"]
##[br]
##[br][color=yellow]@returns[/color]: [constant void]	
func progressDay(direction):
	
	if direction == "forward":
		day += 1
	else:
		day -= 1
		
	if day == 0:
		if month == 2:
			if year == 2000:
				day = 29
			else:
				day = 28
		elif month in [1, 5, 8, 10]:
			day = 31
		else:
			day = 30
			
		month -= 1
	elif (day==28 and month == 2) or (day==29 and month == 2 and year == 2000) or (day == 30 and month in [1, 5, 8, 10]) or (day==31 and month in [0, 2, 4, 6, 7, 9, 11]):
			day = 1
			month += 1
			
	if month == 0:
		month = 11
		year -= 1
	elif month == 12:
		month = 1
		year += 1
		
##Pixel-to-Viewport Height conversion
##[br]
##[br][color=yellow]@param[/color]:
##[br][member px] - [member int] Value
##[br]
##[br][color=yellow]@returns[/color]: [constant vh]
func getPXToVH(px:int)->int:
	return px / get_viewport().get_visible_rect().size[1] * 100
	
##Pixel-to-Viewport Width conversion
##[br]
##[br][color=yellow]@param[/color]:
##[br][member px] - [member int] Value
##[br]
##[br][color=yellow]@returns[/color]: [constant vw]
func getPXToVW(px:int)->int:
	return px / get_viewport().get_visible_rect().size[0] * 100
	
##Viewport Height-to-Pixel conversion
##[br]
##[br][color=yellow]@param[/color]:
##[br][member vh] - [member int] Value
##[br]
##[br][color=yellow]@returns[/color]: [constant px]
func getVHToPX(vh:int)->int:
	@warning_ignore("integer_division", "narrowing_conversion")
	return vh / 100 * get_viewport().get_visible_rect().size[1]
	
##Viewport Width-to-Pixel conversion
##[br]
##[br][color=yellow]@param[/color]:
##[br][member vw] - [member int] Value
##[br]
##[br][color=yellow]@returns[/color]: [constant px]
func getVWToPX(vw:int)->int:
	@warning_ignore("integer_division", "narrowing_conversion")
	return vw / 100 * getVW()
	get_viewport().get_visible_rect().size[0]
	
##Gets the viewport height from the window
##[br]
##[br][color=yellow]@param[/color]: [constant None]
##[br]
##[br][color=yellow]@returns[/color]: [constant vh]
func getVH():
	return get_viewport().get_visible_rect().size[1] / 100.0
	
##Gets the viewport height from the window
##[br]
##[br][color=yellow]@param[/color]: [constant None]
##[br]
##[br][color=yellow]@returns[/color]: [constant vh]
func getVW():
	return get_viewport().get_visible_rect().size[0] / 100.0
	
##Converts a position into viewport height
##[br]
##[br][color=yellow]@param[/color]: [constant None]
##[br][member position] - [member int] Value
##[br][color=yellow]@returns[/color]: [constant vh]
func getARelativePosition(position:int)->int:
	return position + getVH()


# FOR ALEX:
# switch to the schedule/time management screen. Passage of time 
# and daily events will be driven from here.
#I likely don't have enough time to implement this, but it's here 
# to work off of
# (does nothing right now)

## Starts the schedule mechanic. 
## [br]
## [br][color=yellow]@param[/color]: None
## [br][color=yellow]@returns[/color]: void
func startSchedule():
	
	## Empties the parameter object
	parameters = {}
	get_tree_ref().change_scene_to_file("res://sce/schedule/schedule.tscn")
	
	
#FOR NAMA
# start a battle with up to three enemies identified by ID.
# pass only as many IDs as the encounter needs; unused slots are "".
# and can safely be ignored if <3 enemies are present
	
## Starts the battle mechanic. 
## [br]
## [br][color=yellow]@param[/color]: None
## [br][color=yellow]@returns[/color]: void
func startBattle(arrEnemies):
	parameters = {}
	parameters["arrEnemies"] = arrEnemies
	get_tree_ref().change_scene_to_file("res://sce/battle/battle.tscn")
	
	
# FOR EUGENE:
# start a conversation by event ID.
# I'm not sure how you implemented conversation, but if they have IDs by
# which you can refer to them, pass in those
# from the event ID and returning to exploration when finished.
	
## Starts the conversation mechanic. 
## [br]
## [br][color=yellow]@param[/color]: None
## [br][color=yellow]@returns[/color]: void
func startConversation(eventID):
	parameters = {}
	parameters["eventID"] = eventID
	get_tree_ref().change_scene_to_file("res://sce/conversation/DialogueBox.tscn")
	
## Starts the exploration mechanic. 
## [br]
## [br][color=yellow]@param[/color]: None
## [br][color=yellow]@returns[/color]: void
func startExploration(levelID, coorX, coorY, levelHeight):
	
	parameters = {}
	parameters["levelID"] = levelID
	parameters["x"] = coorX
	parameters["y"] = coorY
	parameters["height"] = levelHeight

	const LEVEL_SCENES: Dictionary = {
		"world1": "res://sce/exploration/world1.tscn",
		"world2": "res://sce/exploration/world2.tscn",
	}

	var scenePath: String = LEVEL_SCENES.get(levelID, "")
	if scenePath == "":
		push_error("startExploration: unknown levelID '%s'. Add it to LEVEL_SCENES in globals.gd." % levelID)
		return

	get_tree_ref().change_scene_to_file(scenePath)

func restart():
	music_player.stop()
	sfx_player.stop()
	parameters = {}
	get_tree_ref().change_scene_to_file("res://sce/main.tscn")

## Scene switch workaround.
##[br]
##[br]Direct overwrite is needed when unit testing for
##scene transitions. Otherwise, Godot's [method get_tree()]
##would've sufficed and not produced an [enum Autoload]
##[color=red]Constant ERROR[/color].
func get_tree_ref():
	if _test_tree_override != null:
		return _test_tree_override
	return get_tree()
	
## Save function
func setSave():
	
	## Values to save
	save_info = {
		0: {
			"name": "mode",
			"value": 0
		},
		1: {
			"name": "inventory",
			"value": inventory
		},
		2: {
			"name": "virtue",
			"value": virtue
		},
		3: {
			"name": "parameters",
			"value": name
		},
		4: {
			"name": "day",
			"value": day
		},
		5: {
			"name": "month",
			"value": month
		},
		6: {
			"name": "year",
			"value": year
		}
	}
	
	## Open save file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json = JSON.stringify(save_info)
	file.close()
	
	## Store information
	file.store_line(json)

## Load save
func getSave():
	
	## If save file does not exist, then create one
	if not FileAccess.file_exists(SAVE_PATH):
		setSave()
		return
	
	## Otherwise, open the file and parse
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var string = file.get_as_text()
	
	var json = JSON.new()
	var parse = json.parse(string)
	
	if parse != OK:
		push_error("Save file parse error: %s" % json.get_error_message())
		return
	
	var data = json.data

	# For each given keys, manually restore the structure
	for key in data.keys():
		save_info[int(key)] = {}
		save_info[int(key)]["name"] = data[key]["name"]
		save_info[int(key)]["value"] = data[key]["value"]
		
	file.close()
