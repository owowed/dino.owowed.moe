class_name LevelVar

const SUPPORTED_TYPES = [
	TYPE_STRING, TYPE_STRING_NAME,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_BOOL,
	TYPE_NIL
]

enum Error {
	UNSUPPORTED_TYPE,
	TYPE_MISMATCH,
	NO_DEFAULT,
	NOT_EXIST,
	INVALID_BOOL
}

var _levelvar = {}
var levelvar_defaults = {}
var levelvar_interface = {}

signal levelvar_changed(name: StringName, value)

func _init(template: Dictionary):
	for k in template:
		if template[k] is Array:
			levelvar_interface[k] = template[k][0]
			levelvar_defaults[k] = template[k][1]
			_levelvar[k] = template[k][1]
		elif template[k] == TYPE_ARRAY:
			push_error(Error.UNSUPPORTED_TYPE, "levelvar value cannot be array")
			levelvar_interface[k] = null
		elif template[k] == TYPE_DICTIONARY:
			push_error(Error.UNSUPPORTED_TYPE, "levelvar value cannot be nested/dictionary")
			levelvar_interface[k] = null
		elif template[k] not in SUPPORTED_TYPES:
			push_error(Error.UNSUPPORTED_TYPE, "unsupported type for levelvar")
			levelvar_interface[k] = null
		else:
			levelvar_interface[k] = template[k]
			reset_var(k)

func check_err_var_exists(name: StringName):
	if not has_var(name):
		push_error(Error.NOT_EXIST, "name %s does not exist on levelvar interface" % name)
		return _levelvar[name]

func has_var(name: StringName):
	return name in levelvar_interface

func get_var(name: StringName, default = null):
	check_err_var_exists(name)
	return _levelvar.get(name, default)
	
func set_var(name: StringName, value):
	check_err_var_exists(name)
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
	check_err_var_exists(name)
	if name in levelvar_defaults:
		_levelvar[name] = levelvar_defaults[name]
		levelvar_changed.emit(name, _levelvar[name])
	else:
		match levelvar_interface[name]:
			TYPE_STRING, TYPE_STRING_NAME: _levelvar[name] = ""
			TYPE_INT: _levelvar[name] = 0
			TYPE_FLOAT: _levelvar[name] = 0.0
			TYPE_BOOL: _levelvar[name] = false
			TYPE_NIL: _levelvar[name] = null
		levelvar_changed.emit(name, _levelvar[name])
	
func get_typeof_var(name: StringName):
	return levelvar_interface[name]
	
static func parse_to(type: int, value):
	match type:
		TYPE_STRING, TYPE_STRING_NAME: return value
		TYPE_INT: return int(float(value))
		TYPE_FLOAT: return float(value)
		TYPE_BOOL: return boolize(value)
		TYPE_NIL: return null

static func boolize(value):
	if value is String or value is StringName: return value.to_lower() == "true" or int(value as String) == 1
	return int(value) == 1
