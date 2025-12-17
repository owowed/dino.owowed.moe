class_name WinnerMenu
extends Control

@onready var final_score_label: Label = $HBoxContainer/FinalScore
@onready var back_button: Button = $HBoxContainer/BackToMap

var _back_callback: Callable

func show_win(score: int, back_callback: Callable) -> void:
	_back_callback = back_callback
	if final_score_label:
		final_score_label.text = "Final Score: %04d" % score
	visible = true
	if back_button:
		back_button.grab_focus()

func _on_back_to_map_pressed() -> void:
	if _back_callback and _back_callback.is_valid():
		_back_callback.call()
