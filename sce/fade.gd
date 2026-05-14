extends CanvasLayer

## Script for fade.tscn

## On load, start the fade
func _ready():
	$BlackFade.modulate.a = 1.0
	$BlackFade.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Start the fade in transition
func fade_in(duration := 1.0, color := Color.BLACK):
	$BlackFade.color = color
	$BlackFade.modulate.a = 0.0
	
	if color == Color.BLACK:
		Globals.play_sfx(preload("res://aud/sfx/fade/fadeInBlack.ogg"), 0.3)
	else:
		Globals.play_sfx(preload("res://aud/sfx/fade/fadeInWhite.ogg"), 0.3)

	
	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate:a", 1.0, duration)
	tween.finished.connect(queue_free)

## Start the fade out transition
func fade_out(duration := 1.0, color := Color.BLACK):
	$BlackFade.color = color
	$BlackFade.modulate.a = 1.0

	if color == Color.BLACK:
		Globals.play_sfx(preload("res://aud/sfx/fade/fadeInBlack.ogg"), 0.3)
	else:
		Globals.play_sfx(preload("res://aud/sfx/fade/fadeInWhite.ogg"), 0.3)

	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate:a", 0.0, duration)
	tween.finished.connect(queue_free)
	
	
func fade_enemy():
	$BlackFade.color = Color.WHITE
	$BlackFade.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate:a", 1.0, 0.7)
	tween.tween_property($BlackFade, "modulate:a", 0.0, 0.7)
	tween.tween_property($BlackFade, "modulate:a", 1.0, 0.4)
	tween.tween_property($BlackFade, "modulate", Color.BLACK, 1.0)
	tween.tween_property($BlackFade, "modulate:a", 1.0, 2.0)
	tween.finished.connect(queue_free)
