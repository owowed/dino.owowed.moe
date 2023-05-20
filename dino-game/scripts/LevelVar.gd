class_name LevelVar

var _levelvar = {}
var _levelvar_template = {}

enum Error {
	UNSUPPORTED_TYPE,
	TYPE_MISMATCH,
	NO_DEFAULT,
	NOT_EXIST,
	INVALID_BOOL
}

signal levelvar_changed(name: StringName, value)

func _init(template: Dictionary):
	_levelvar_template = template
	
	for k in _levelvar_template.keys():
		if _levelvar_template[k] is Array:
			_levelvar[k] = _levelvar_template[k][1]
		elif _levelvar_template[k] == TYPE_ARRAY:
			push_error(Error.UNSUPPORTED_TYPE, "levelvar value cannot be array")
			_levelvar_template[k]
		elif _levelvar_template[k] is Dictionary or _levelvar_template[k] == TYPE_DICTIONARY:
			push_error(Error.UNSUPPORTED_TYPE, "levelvar value cannot be nested/dictionary")
			_levelvar_template[k] = null

func has_var(name: StringName):
	return name in _levelvar_template

func get_var(name: StringName, default = null):
	if has_var(name):
		return _levelvar.get(name, default)
	else:
		return _levelvar[name]
	
func set_var(name: StringName, value):
	if not has_var(name):
		push_error(Error.NOT_EXIST, "levelvar does not exist")
		return Error.NOT_EXIST
	if get_typeof_var(name) == typeof(value):
		_levelvar[name] = value
		levelvar_changed.emit(name, _levelvar[name])
	else:
		if value is String:
			set_var(name, parse_to(get_typeof_var(name), value))
		else:
			push_error(Error.TYPE_MISMATCH,
				"setting levelvar: value type does not match with levelvar")
			return Error.TYPE_MISMATCH

func reset_var(name: StringName):
	if typeof(_levelvar_template[name]) != TYPE_ARRAY or _levelvar_template.size() < 2:
		match _levelvar_template[name]:
			TYPE_STRING, TYPE_STRING_NAME: _levelvar[name] = ""
			TYPE_INT: _levelvar[name] = 0
			TYPE_FLOAT: _levelvar[name] = 0.0
			TYPE_BOOL: _levelvar[name] = false
		levelvar_changed.emit(name, _levelvar[name])
	else:
		_levelvar[name] = _levelvar_template[name][1]
		levelvar_changed.emit(name, _levelvar[name])
	
func get_typeof_var(name: StringName):
	if _levelvar_template[name] is Array: return _levelvar_template[name][0]
	else: return _levelvar_template[name]
	
func parse_to(type, value: String):
	match type:
		TYPE_INT: return int(float(value))
		TYPE_FLOAT: return float(value)
		TYPE_BOOL: return boolize(value)

func boolize(value):
	return value == "true" or int(value) == 1
