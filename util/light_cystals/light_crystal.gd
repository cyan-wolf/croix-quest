extends Node2D

signal activated

@export var _is_on: bool = true
@export var _light_color: Color = Color("ffffff")

@onready var _point_light: PointLight2D = self.get_node("PointLight2D")

func _ready():
	_point_light.color = _light_color

	_update_light()


func toggle() -> void:
	_is_on = not _is_on
	_update_light()


func turn_on() -> void:
	_is_on = true
	_update_light()


func turn_off() -> void:
	_is_on = false
	_update_light()


# Updates the light's state in the scene.
func _update_light() -> void:
	if _is_on:
		self.activated.emit()
		_activate_light()
	else:
		_deactivate_light()


func _activate_light() -> void:
	_point_light.show()


func _deactivate_light() -> void:
	_point_light.hide()

