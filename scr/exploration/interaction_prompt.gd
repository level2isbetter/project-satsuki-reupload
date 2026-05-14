extends PanelContainer

#interaction prompt UI that shows when player is near interactables
# most of the print() code here is for testing purposes.
# can be deleted when not needed anymore

@onready var label: Label = $MarginContainer/PromptLabel

func _ready() -> void:
	# start hidden and only show when applicable
	hide()
	print("InteractionPrompt initialized")

func showPrompt(text: String) -> void:
	print("showPrompt called with text: '%s'" % text)
	if label:
		label.text = text
		print("Label text set")
	else:
		print("ERROR: Label is null!")
	show()
	print("Prompt visibility: %s" % visible)

func hidePrompt() -> void:
	print("hidePrompt called")
	hide()

func updateText(text: String) -> void:
	if label:
		label.text = text
