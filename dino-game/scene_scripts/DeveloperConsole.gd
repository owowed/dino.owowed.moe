extends Control

@export var dino: Dino
@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var level: RunnerDesert = get_owner()

var active = false:
	get: return active
	set(value):
		active = value
		visible = active
		if active: line_edit.grab_focus()
		elif line_edit.text.length() > 0 and line_edit.text[-1] == "`": line_edit.delete_char_at_caret()

func _process(delta):
	if Input.is_action_just_pressed("ui.developer_console.toggle"):
		active = !visible
		
func _on_line_edit_focus_entered():
	dino.can_move = false

func _on_line_edit_focus_exited():
	dino.can_move = true

func _on_line_edit_text_submitted(text: String):
	var args = text.split(" ")
	var levelvar_name = args[0]
	var levelvar_value = args[1] if args.size() > 1 else null
	
	if not level.levelvar.has_var(levelvar_name): return
	
	if levelvar_value == null and level.levelvar.get_typeof_var(levelvar_name) == TYPE_BOOL:
		level.levelvar.set_var(levelvar_name, not level.levelvar.get_var(levelvar_name))
	else:
		level.levelvar.set_var(levelvar_name, levelvar_value)
