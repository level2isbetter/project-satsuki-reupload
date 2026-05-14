extends Interactable

@export var targetLevelID: String = ""
@export var targetX: int = 0
@export var targetY: int = 0
@export var targetHeight: int = 0
# to Alex: this mostly just exists as an option.
# for testing purposes, I set it to be interactable, but depending
#on how you want to implement the transition, you could set it to autoEnter 
#and just have the player walk into it without pressing "E".
@export var autoEnter: bool = false

func _ready() -> void:
	super._ready()
	autoInteract = autoEnter
	interactionPrompt = "Press E to enter"

func _onInteract(_interactor: Node2D) -> void:
	if targetLevelID == "":
		push_warning("ZonePortal '%s' has no targetLevelID set." % name)
		return
	Globals.play_sfx(preload("res://aud/sfx/exploration/transition.ogg"))
	Globals.startExploration(targetLevelID, targetX, targetY, targetHeight)
