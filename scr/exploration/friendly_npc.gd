extends Interactable
class_name FriendlyNPC

# friendly NPC that starts a conversation when the player presses E -
# calls Global.startConversation(conversationID) directly.

# as always, print() statements are for testing purposes and can be removed whenever

#note to Eugene: the conversationID is just a string 
# that you can use to identify which conversation to start.

#if you programmed conversations a different way, message me on Discord regarding
# specifics and I can make adjustments as necessary.

@export var npcName: String = "NPC"
@export var conversationID: String = ""

func _ready() -> void:
	super._ready()
	autoInteract = false
	oneTimeUse = false
	interactionPrompt = "Press E to talk to %s" % npcName
	

func _onInteract(_interactor: Node2D) -> void:
	if conversationID == "":
		push_warning("FriendlyNPC '%s' has no conversationID set." % npcName)
		return
	print("[Conversation] Starting conversation with %s (ID: %s)" % [npcName, conversationID])
	Globals.startConversation(conversationID)
