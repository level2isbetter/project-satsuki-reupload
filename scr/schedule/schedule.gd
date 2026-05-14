extends Node

## Schedule mechanic script
## * Runs under the schedule.tscn
## * Has subsidary on nde_progress.gd
## * Can communicate with conversation
##   and exploration mechanics.

## Constants
const BLANK_TEXTURE = "res://img/blank_half.png"

## Variables
var itemSelected = -1;
var isSelected = false;
var schedule_slide_state = 0

## Function on populating information
func _slide_in_info(type) -> void:
	
	## Make the information container visible
	$txt_info.visible = true
	
	## If sliding hasn't started, start it.
	if $txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.is_stopped():
		$txt_info/vbox_info_container/hbox_info_container/tmrSlideStart.start()
		Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))
	
	## Get entry data from the parameter
	var entry = _get_entry(type, Globals.schedule_values)
			
	# If that entry is not empty
	if entry != {}:
		
		## Populate the information
		$txt_info/vbox_info_container/hbox_info_container/vbox_img/img_info.texture = entry["image"]
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/lblInfo.text = entry["name"]
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/lblInfoText.text = entry["info"]
		
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/vboxParameter1/lblParameter1.text = entry["para1_name"]
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/vboxParameter2/lblParameter2.text = entry["para2_name"]
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/vboxParameter3/lblParameter3.text = entry["para3_name"]
		
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/vboxParameter1/prgParameter1.value = entry["para1"]
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/vboxParameter2/prgParameter2.value = entry["para2"]
		$txt_info/vbox_info_container/hbox_info_container/vbox_info/vboxParameter3/prgParameter3.value = entry["para3"]

## Entry mapping
func _get_entry(type, dict) -> Dictionary: 
	for key in dict:
		var entry = dict[key]
		
		if entry["name"] == type:
			return entry
			
	return {}

## Make the info container invisible
func _slide_out_info() -> void:
	$txt_info.visible = false

###########

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_calendar()
	Fade.fade_out(1, Color.WHITE)
	
	Globals.play_music(preload("res://aud/mus/Whimsical.ogg"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not $txt_info/vbox_info_container/hbox_info_container/tmrSlideStart.is_stopped() && $txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.is_stopped():
		$txt_info.position.y -= 10
		
	if $txt_info/vbox_info_container/hbox_info_container/tmrSlideStart.is_stopped() && not $txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.is_stopped():
		$txt_info.position.y += 10
		
	if schedule_slide_state == -1:
		$txtSchedule.position.x -= 10
	elif schedule_slide_state == 1:
		$txtSchedule.position.x += 10

## Button mapper - Rest 1 timer start
func _on_btn_rest_1_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_rest/hbox_rest/btnRest1/tmrRest1.start()

## Timer -- Rest 1 info population
func _on_tmr_rest_1_timeout() -> void:
	_slide_in_info("sleep")

## Timer -- Rest 2 info population
func _on_tmr_rest_2_timeout() -> void:
	_slide_in_info("interact")

## Info container - positioning
func _on_vbox_info_container_ready() -> void:
	$txt_info.position.y = DisplayServer.window_get_size().y

## Button mapper - Rest 1 info slider
func _on_btn_rest_1_mouse_exited() -> void:	
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))
## Timer - Slider hideout
func _on_tmr_slide_end_timeout() -> void:
	$txt_info.position.y = DisplayServer.window_get_size().y
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideFinish.ogg"))

## Button mapper - Rest 2 timer start
func _on_btn_rest_2_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_rest/hbox_rest/btnRest2/tmrRest2.start()

## Button mapper - Rest 3 timer start
func _on_btn_rest_3_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_rest/hbox_rest/btnRest3/tmrRest3.start()

## Button mapper - Rest 3 hover
func _on_tmr_rest_3_timeout() -> void:
	_slide_in_info("talk")

## Button mapper - Rest 2 info slider
func _on_btn_rest_2_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))
## Button mapper - Rest 3 info slider
func _on_btn_rest_3_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

## Function map to the item object
func placeItem(item):
	var entry = _get_entry(item, Globals.schedule_values)
	Globals.itemSelection[itemSelected] = entry
	get_node("txtClock/grdSelection/tbnItem" + str(itemSelected)).texture_normal = entry["image"]
	item_selcted(-1)
	Globals.play_sfx(preload("res://aud/sfx/schedule/item_place.mp3"))

## Determine status to open the schedule container
func item_selcted(itemNumber):
	if !isSelected or itemSelected != itemNumber:
		isSelected = true
		
		if ($txtSchedule.position.x + $txtSchedule.size.x) < 0:
			schedule_slide_state = 1
			$tmrChanceScheduleSlide.start()
			Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))
		else:
			Globals.play_sfx(preload("res://aud/sfx/ui/menu/move.ogg"))
		
		itemSelected = itemNumber
	else:
		isSelected = false
		itemSelected = -1
		schedule_slide_state = -1
		$tmrChanceScheduleSlide.start()
		Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))
		
	

## Button mapper -- Item select 0
func _on_tbn_item_0_pressed() -> void:
	item_selcted(0)

## Button mapper -- Item select 1
func _on_tbn_item_1_pressed() -> void:
	item_selcted(1)

## Button mapper -- Item select 2
func _on_tbn_item_2_pressed() -> void:
	item_selcted(2)

## Button mapper -- Item select 3
func _on_tbn_item_3_pressed() -> void:
	item_selcted(3)

## Button mapper -- Rest item 1
func _on_btn_rest_1_pressed() -> void:
	placeItem("sleep")

## Button mapper -- Rest item 2
func _on_btn_rest_2_pressed() -> void:
	placeItem("interact")

## Button mapper -- Rest item 3
func _on_btn_rest_3_pressed() -> void:
	placeItem("talk")

## 'End' Button function on handling mechanic's progress
func _on_btn_end_pressed() -> void:

	var error = 0

	for i in range(4):
		if Globals.itemSelection[i] == {}:
			error += 1
			
	if error != 4:
	
		## Process the progress from ndeProgress
		$ndeProgress.visible = true
		Globals.play_music(preload("res://aud/mus/Startup.ogg"))
		$ndeProgress._schedule_start()
		
		
		## For each schedule item after the nde_progress.gd function
		for i in range(4):
			
			## If that item is not empty
			if Globals.itemSelection[i] != {}:
				
				## Get its entry and its associated parameters
				var entry = Globals.itemSelection[i]
				var parameter1 = _get_entry(entry["para1_name"], Globals.virtue)
				var parameter2 = _get_entry(entry["para2_name"], Globals.virtue)
				var parameter3 = _get_entry(entry["para3_name"], Globals.virtue)
				
				## Console print
				print("Prior change")
				print("Parameter 1 - " + entry["para1_name"])
				print("Value: " + str(parameter1["value"]))
				print("Parameter 2 - " + entry["para2_name"])
				print("Value: " + str(parameter2["value"]))
				print("Parameter 3 - " + entry["para3_name"])
				print("Value: " + str(parameter3["value"]))
				
				## Make the said parameter change
				Globals.progress(parameter1, entry["para1"], "level")
				Globals.progress(parameter2, entry["para2"], "level")
				Globals.progress(parameter3, entry["para3"], "level")
				
				## Console print
				print("\nNew change")
				print("Parameter 1 - " + entry["para1_name"])
				print("Value: " + str(parameter1["value"]))
				print("Parameter 2 - " + entry["para2_name"])
				print("Value: " + str(parameter2["value"]))
				print("Parameter 3 - " + entry["para3_name"])
				print("Value: " + str(parameter3["value"]))
				print("\n")
				
			## Empty the object
			Globals.itemSelection[i] = {}
			get_node("txtClock/grdSelection/tbnItem" + str(i)).texture_normal = load(BLANK_TEXTURE)
			isSelected = false
			itemSelected = -1
	else:
		Globals.play_sfx(preload("res://aud/sfx/ui/menu/warning.ogg"))

## Update the calendar visual		
func _update_calendar():
	var day = str(Globals.day)
	
	if day.length() == 1:
		day = "0" + day
	
	$box_info/hbox_info_separator/lblDay.text = day
	$box_info/hbox_info_separator/vbox_info_Day/lblMonth.text = Globals.monthName[Globals.month]["name"]
	$box_info/hbox_info_separator/vbox_info_Day/lblYear.text = str(Globals.year)


func _on_tmr_chance_schedule_slide_timeout() -> void:
	schedule_slide_state = 0
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideFinish.ogg"))


func _on_btn_explore_1_pressed() -> void:
	placeItem("overworld")


func _on_btn_explore_1_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_explore/hbox_explore/btnExplore1/tmrExplore1.start()

func _on_btn_explore_1_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

## Explore timer timeout

func _on_tmr_explore_2_timeout() -> void:
	_slide_in_info("null")


func _on_tmr_explore_3_timeout() -> void:
	_slide_in_info("null")

## Study timer timeout

func _on_btn_study_3_timeout() -> void:
	_slide_in_info("null")


func _on_btn_study_2_timeout() -> void:
	_slide_in_info("null")


func _on_btn_study_1_timeout() -> void:
	_slide_in_info("null")

## Work timer timeout

func _on_btn_work_3_timeout() -> void:
	_slide_in_info("null")


func _on_btn_work_2_timeout() -> void:
	_slide_in_info("null")


func _on_btn_work_1_timeout() -> void:
	_slide_in_info("null")
	
## Explore buttons pressed

func _on_tmr_explore_1_timeout() -> void:
	_slide_in_info("overworld")

func _on_btn_explore_2_pressed() -> void:
	placeItem("null")

func _on_btn_explore_3_pressed() -> void:
	placeItem("null")

## Study buttons pressed

func _on_btn_study_3_pressed() -> void:
	placeItem("null")

func _on_btn_study_2_pressed() -> void:
	placeItem("null")

func _on_btn_study_1_pressed() -> void:
	placeItem("null")

## Work buttons pressed

func _on_btn_work_3_pressed() -> void:
	placeItem("null")

func _on_btn_work_2_pressed() -> void:
	placeItem("null")

func _on_btn_work_1_pressed() -> void:
	placeItem("null")


func _on_btn_explore_2_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_explore/hbox_explore/btnExplore2/tmrExplore2.start()


func _on_btn_explore_2_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

func _on_btn_explore_3_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_explore/hbox_explore/btnExplore3/tmrExplore3.start()
	

func _on_btn_explore_3_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

func _on_btn_study_3_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_study/hbox_study/btnStudy3/tmrStudy3.start()


func _on_btn_study_3_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()


func _on_btn_study_2_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_study/hbox_study/btnStudy2/tmrStudy2.start()


func _on_btn_study_2_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

func _on_btn_study_1_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_study/hbox_study/btnStudy1/tmrStudy1.start()


func _on_btn_study_1_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

func _on_btn_work_3_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_work/hbox_work/btnWork3/tmrWork3.start()


func _on_btn_work_3_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

func _on_btn_work_2_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_work/hbox_work/btnWork2/tmrWork2.start()


func _on_btn_work_2_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))

func _on_btn_work_1_mouse_entered() -> void:
	$txtSchedule/grd_schedule/vbox_work/hbox_work/btnWork1/tmrWork1.start()


func _on_btn_work_1_mouse_exited() -> void:
	$txt_info/vbox_info_container/hbox_info_container/tmrSlideEnd.start()
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideStart.ogg"))


func _on_tmr_slide_start_timeout() -> void:
	Globals.play_sfx(preload("res://aud/sfx/schedule/slideFinish.ogg"))
