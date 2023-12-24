extends Node2D
class_name LightCrystal

signal activated
signal deactivated

@export var _is_on: bool = true
@export var _light_color: Color = Color("ffffff")
@export var _light_scale: float = 1.0
@export var _energy: float = 1.0

@onready var _point_light: PointLight2D = self.get_node("PointLight2D")
@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

func _ready():
	_point_light.color = _light_color
	_point_light.texture_scale = _light_scale
	_point_light.energy = _energy

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
		self.deactivated.emit()
		_deactivate_light()


func _activate_light() -> void:
	_point_light.show()
	_sprite.play("on")


func _deactivate_light() -> void:
	_point_light.hide()
	_sprite.play("off")

