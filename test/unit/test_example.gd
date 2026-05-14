extends GutTest

## Node tree for bridge testing
class FakeTree:
	var last_scene_path = null
	func change_scene_to_file(path):
		last_scene_path = path

## Engine version check
func test_version():
	var v = Engine.get_version_info()
	assert_eq(v.major, 4, "Godot's version needs to be 4.6")
	assert_eq(v.minor, 6, "Godot's version needs to be 4.6")

## Day progress function check
func test_day_progress():
	var previousDay = Globals.day
	Globals.progressDay("forward")
	assert_eq(Globals.day, previousDay + 1)

	Globals.progressDay("backward")
	assert_eq(Globals.day, previousDay)

## Level progress function check
func test_level_progress():
	var virtue = Globals.virtue[0]
	var rank = virtue["rank"]
	var level = virtue["level"]

	Globals.progress(virtue, 100, "rank")
	assert_eq(virtue["rank"], rank + 1, "Rank up mismatch; Changes in the code")

	Globals.progress(virtue, -100, "rank")
	assert_eq(virtue["rank"], rank, "Rank down mismatch; Changes in the code")

	Globals.progress(virtue, 100, "level")
	assert_eq(virtue["level"], level + 1, "Level up mismatch; Changes in the code")

	Globals.progress(virtue, -100, "level")
	assert_eq(virtue["level"], level, "Level down mismatch; Changes in the code")

## Bridge check
func test_bridges():
	var fake_tree = FakeTree.new()

	Globals._test_tree_override = fake_tree

	Globals.startSchedule()
	assert_eq(fake_tree.last_scene_path, "res://sce/schedule/schedule.tscn",
	"Schedule path mismatch")

	Globals.startExploration("world1", 0, 0, 0)
	assert_eq(fake_tree.last_scene_path, "res://sce/exploration/world1.tscn",
	"Exploration path mismatch")
	
	Globals.startBattle([])
	assert_eq(fake_tree.last_scene_path, "res://sce/battle/battle.tscn",
	"Battle path mismatch")
	
	#Globals.startConversation(0)
	#assert_eq(fake_tree.last_scene_path, "res://sce/conversation/conversation.tscn",
	#"Conversation path mismatch")

	# Clean up
	Globals._test_tree_override = null

## Viewport check
func test_viewport():
	var width = 1920
	var height = 1080
	
	var width_VW = Globals.getPXToVW(width)
	var height_VH = Globals.getPXToVH(height)
	
	assert_eq(width_VW, width / get_viewport().get_visible_rect().size[0] * 100, "VW Calculation mismatch")
	assert_eq(height_VH, height / get_viewport().get_visible_rect().size[1] * 100, "VH Calculation mismatch")	
