extends Node2D

## Variables
var ticks = 0
var max_ticks = 0
var current_item = 0
var items = {}

## Start the script
func _schedule_start():
	_update_calender()
	
	for i in range(4):
		if Globals.itemSelection[i] != {}:
			max_ticks += 7
			items[current_item] = Globals.itemSelection[i]
			current_item += 1
		
	Fade.fade_out(1.0, Color.WHITE)
	current_item = 0
	$tmrHoldStart.start()
	
## Finish schedule
func _schedule_done():
	visible = false
	ticks = 0
	max_ticks = 0
	current_item = 0
	get_parent()._update_calendar()
	
	$music.stop()
	Globals.play_music(preload("res://aud/mus/Whimsical.ogg"))
	
	Fade.fade_out(1.0, Color.WHITE)
	
## Update the calender visual
func _update_calender():
	var day = str(Globals.day)
	var calender
	
	if day.length() == 1:
		day = "0" + day
		
	calender = str(day) + " " + Globals.monthName[Globals.month]["name_full"] + ", " + str(Globals.year)
	
	$lblCalender.text = calender
	
## Timer tick timeout
func _on_tmr_tick_timeout() -> void:
	ticks += 1
	
	if ticks % 8 == 0:
		current_item += 1
		_check_item()
	
	Globals.progressDay("forward")
	_update_calender()
	
	if ticks == max_ticks:
		$tmrTick.stop()
		$tmrHoldEnd.start()
		
func _check_item() -> void:
	
	if items[current_item]["name"] == "overworld":
		Fade.fade_in($tmrHoldTransition.wait_time+0.100)
		$tmrHoldTransition.start()


func _on_tmr_hold_end_timeout() -> void:
	_schedule_done()


func _on_tmr_hold_start_timeout() -> void:
	_check_item()	
	$tmrTick.start()


func _on_tmr_hold_transition_timeout() -> void:
	if items[current_item]["name"] == "overworld":
		Globals.startExploration("world1", 0, 0, 0)
