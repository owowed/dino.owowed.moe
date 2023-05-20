extends Control

@onready var dino: Dino = get_owner().get_node("Dino")
@onready var line_edit = $VBoxContainer/LineEdit
@onready var level: RunnerDesert = get_owner()

func _ready():
	line_edit.focus_entered.connect(func():
		dino.can_move = false
	)
	line_edit.focus_exited.connect(func():
		dino.can_move = true
	)
	line_edit.text_submitted.connect(func(text: String):
		var args = text.split(" ")
		level.cvar[args[0]] = boolize(args[1])
		print(level.cvar, text)
	)

func _process(delta):
	if Input.is_action_just_pressed("ui.toggle_developer_console"):
		visible = !visible
		if visible: line_edit.grab_focus()
		
func boolize(str: String):
	return str == "true" or str == "1"


