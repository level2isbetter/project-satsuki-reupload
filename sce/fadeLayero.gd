extends Node

## Open up the fade scene
var FadeScene := preload("res://sce/fade.tscn")

## Fade in calculation
func fade_in(duration := 1.0, color := Color.BLACK):
	var fade := FadeScene.instantiate()
	get_tree().current_scene.add_child(fade)
	fade.fade_in(duration, color)
	
## Fade out calculation
func fade_out(duration := 1.0, color := Color.BLACK):
	var fade := FadeScene.instantiate()
	get_tree().current_scene.add_child(fade)
	fade.fade_out(duration, color)
	
	## Fade out calculation
func fade_enemy():
	var fade := FadeScene.instantiate()
	get_tree().current_scene.add_child(fade)
	fade.fade_enemy()
