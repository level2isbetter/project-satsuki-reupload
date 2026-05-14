
extends Control

func _ready():
	visible = false

func open():
	visible = true

func close():
	visible = false

func _on_back_pressed():
	close()
	
