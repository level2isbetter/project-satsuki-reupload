extends Node2D

## main.gd
## * Part of the main.tscn

var selection = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Fade.fade_out()
	$tmrStart.start()
	Globals.play_music(preload("res://aud/mus/TheOpening_REAL.ogg"))
	print(Globals.save_info)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tmr_start_timeout() -> void:
	$tmrStart.stop()
	$cntTitle/imgEnter.visible = true
	$tmrFlick.start()

func _on_tmr_flick_timeout() -> void:
	$cntTitle/imgEnter.visible = !$cntTitle/imgEnter.visible
	
## Keyboard events
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if $cntTitle.visible:
			$tmrTransition.start()
			Fade.fade_in($tmrTransition.wait_time)
			selection = 1
			Globals.play_sfx(preload("res://aud/sfx/menu/pressEnter.ogg"), 1, 1)
			
	if event.is_action_pressed("ui_cancel"):
		if selection != 0:
			$tmrTransition.start()
			Fade.fade_in($tmrTransition.wait_time)
			selection = 0

func _on_tmr_transition_timeout() -> void:
	if selection == 1:
		$cntTitle.visible = false
		$cntSelection.visible = true
		Fade.fade_out($tmrTransition.wait_time)
	elif selection == 2:
		$tmrMode.wait_time = $tmrTransition.wait_time
		$tmrMode.start()
	elif selection == 3:
		$tmrMode.wait_time = $tmrTransition.wait_time
		$tmrMode.start()
	elif selection == 4:
		$tmrMode.wait_time = $tmrTransition.wait_time
		$tmrMode.start()
	elif selection == 5:
		$tmrMode.wait_time = $tmrTransition.wait_time
		$tmrMode.start()
	else:
		$cntTitle.visible = true
		$cntSelection.visible = false
		Fade.fade_out($tmrTransition.wait_time)


func _on_btn_schedule_pressed() -> void:
	$tmrTransition.start()
	Fade.fade_in($tmrTransition.wait_time+0.3, Color.WHITE)
	selection = 2
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/forward.ogg"), 1, 1)

func _on_tmr_mode_timeout() -> void:
	print(selection)
	
	if selection == 2:
		Globals.startSchedule()
	elif selection == 3:
		Globals.startBattle([])
	elif selection == 4:
		Globals.startConversation(0)
	elif selection == 5:
		Globals.startExploration("world1", 0, 0, 0)


func _on_btn_battle_pressed() -> void:
	$tmrTransition.start()
	Fade.fade_in($tmrTransition.wait_time+0.3, Color.WHITE)
	selection = 3
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/forward.ogg"), 1, 1)

func _on_btn_conversation_pressed() -> void:
	$tmrTransition.start()
	Fade.fade_in($tmrTransition.wait_time+0.3, Color.WHITE)
	selection = 4
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/forward.ogg"), 1, 1)

func _on_btn_exploration_pressed() -> void:
	$tmrTransition.start()
	Fade.fade_in($tmrTransition.wait_time+0.3, Color.WHITE)
	selection = 5
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/forward.ogg"), 1, 1)

func _on_btn_exploration_mouse_entered() -> void:
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/move.ogg"))

func _on_btn_conversation_mouse_entered() -> void:
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/move.ogg"))


func _on_btn_battle_mouse_entered() -> void:
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/move.ogg"))


func _on_btn_schedule_mouse_entered() -> void:
	Globals.play_sfx(preload("res://aud/sfx/ui/menu/move.ogg"))
