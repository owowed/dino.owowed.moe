extends Control

@onready var developer_console = get_owner().get_node("CanvasLayer/DeveloperConsole")

var active = false:
	get: return active
	set(value):
		active = value
		visible = active
		get_tree().paused = active

func _process(delta):
	if Input.is_action_just_pressed("ui.pause_menu.toggle"):
		active = !active

func _on_resume_pressed():
	active = false

func _on_quit_pressed():
	get_tree().quit()

func _on_dev_console_pressed():
	developer_console.active = !developer_console.active
