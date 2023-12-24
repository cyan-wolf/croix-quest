extends Node2D

# const LightCrystal := preload("res://util/light_cystals/light_crystal.gd")

signal activated
signal deactivated

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@export var _light_crystal: LightCrystal

var _is_activated := false

func _ready() -> void:
	# Connect signals.
	self.activated.connect(_on_self_activated)
	self.deactivated.connect(_on_self_deactivated)


func _physics_process(_delta: float) -> void:
	# Get the state of the switch at the start of the frame.
	var was_activated := _is_activated

	# Reset `_is_activated`.
	_is_activated = false

	# If any of the overlapping bodies are a 'Pushable Rock', then set
	# '_is_activated' to `true`.
	for body in _hitbox.get_overlapping_bodies():
		if body.is_in_group("pushable_rock_collision_hitbox"):
			_is_activated = true
			break

	# If the switch was previously activated, but isn't anymore, then 
	# that means that the switch has been deactivated.
	if was_activated and not _is_activated:
		self.deactivated.emit()

	# If the switch wasn't previously activated, but now is, then 
	# that means that the switch has been activated.
	elif not was_activated and _is_activated:
		self.activated.emit()

	# This means that the switch hasn't changed state, therefore 
	# no signals should be fired.
	else:
		pass

		
func _on_self_activated() -> void:
	_light_crystal.turn_on()


func _on_self_deactivated() -> void:
	_light_crystal.turn_off()


