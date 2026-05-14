class_name BattleResults extends RefCounted

static func show_outcome(options: CanvasItem, crosshair: CanvasItem, spell_menu_ui: SpellMenuUI, menu_to_show: Control, audio_player: AudioStreamPlayer, sound: AudioStream, title: String, message: String) -> void:
	print("\n=== " + title + " ===")
	print(message)

	if sound:
		Globals.play_music(sound, 1.0, false)

	if options:
		options.hide()
	if crosshair:
		crosshair.hide()
	if spell_menu_ui:
		spell_menu_ui.close()
	if menu_to_show:
		menu_to_show.show()

static func continue_from_victory(victory_menu: Control, audio_player: AudioStreamPlayer) -> void:
	if victory_menu:
		victory_menu.hide()
	
	Globals.stop_music()
	print("transitioning to next scene...")
	
