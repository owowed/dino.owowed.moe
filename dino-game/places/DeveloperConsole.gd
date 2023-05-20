extends Control

@onready var dino: Dino = get_owner().get_node("Dino")
@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
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
		var levelvar_name = args[0]
		var levelvar_value = args[1] if args.size() > 1 else null
		
		if not level.levelvar.has_var(levelvar_name): return
		
		if levelvar_value == null and level.levelvar.get_typeof_var(levelvar_name) == TYPE_BOOL:
			level.levelvar.set_var(levelvar_name, not level.levelvar.get_var(levelvar_name))
		else:
			level.levelvar.set_var(levelvar_name, levelvar_value)
	)

func _process(delta):
	if Input.is_action_just_pressed("ui.toggle_developer_console"):
		visible = !visible
		if visible: line_edit.grab_focus()
		else: line_edit.delete_char_at_caret()


