extends Control

@export var developer_console: Control

var active = false:
	get: return active
	set(value):
		active = value
		visible = active
		get_tree().paused = active

func _process(_delta):
	if Input.is_action_just_pressed("ui.pause_menu.toggle"):
		active = !active

func _on_resume_pressed():
	active = false

func _on_quit_pressed():
	get_tree().quit()
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval('alert("Game exited!")')

func _on_dev_console_pressed():
	if developer_console != null:
		developer_console.active = !developer_console.active
