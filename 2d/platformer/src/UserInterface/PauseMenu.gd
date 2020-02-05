extends Control


onready var resume_button = $VBoxContainer/ResumeButton


func _ready():
	visible = false


func open():
	visible = true
	resume_button.grab_focus()


func close():
	visible = false


func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
