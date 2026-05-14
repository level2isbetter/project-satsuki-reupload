extends Node

signal line_changed(character: String, text: String)
signal choices_changed(choices: Array)
signal event_changed(event_id: int)
signal actions_requested(actions: Array)
signal finished()

var events: Dictionary = {}
var current_event: int = 0
var index: int = 0

var _last_event: int = -1


func start(new_events: Dictionary, start_event: int = 0) -> void:
	events = new_events
	current_event = start_event
	index = 0
	_last_event = -1
	_emit_current()


func next_line() -> void:
	if events.is_empty():
		return
	index += 1
	_emit_current()


func choose(next_event: int) -> void:
	current_event = next_event
	index = 0
	_emit_current()

func _emit_current() -> void:
	if not events.has(current_event):
		finished.emit()
		return

	var ev: Dictionary = events[current_event]

	# Fire event_changed + actions only when the event actually changes
	if current_event != _last_event:
		_last_event = current_event
		event_changed.emit(current_event)

		if ev.has("actions"):
			actions_requested.emit(ev["actions"])

	var dialogue: Array = ev.get("text", [])

	# End of event behavior
	if index >= dialogue.size():
		if ev.has("choices"):
			choices_changed.emit(ev["choices"])
		elif ev.has("next_event"):
			choose(int(ev["next_event"]))
		else:
			finished.emit()
		return

	var line: Dictionary = dialogue[index]
	line_changed.emit(line.get("character", ""), line.get("text", ""))
