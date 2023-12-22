extends Node2D

signal activated
signal deactivated

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

var _is_activated := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Get the state of the switch at the start of the frame.
	var was_activated := _is_activated

	# Reset `_is_activated`.
	_is_activated = false

	# If any of the overlapping hitboxes belong to a 'Pushable Rock', then set
	# '_is_activated' to `true`.
	for hitbox in _hitbox.get_overlapping_areas():
		if hitbox.get_parent().is_in_group("pushable_rock_collision_hitbox"):
			_is_activated = true
			break

	# If the switch was previously activated, but isn't anymore, then 
	# that means that the switch has been deactivated.
	if was_activated and not _is_activated:
		print_debug("off")
		self.deactivated.emit()

	# If the switch wasn't previously activated, but now is, then 
	# that means that the switch has been activated.
	elif not was_activated and _is_activated:
		print_debug("on")
		self.activated.emit()

	# This means that the switch hasn't changed state, therefore 
	# no signals should be fired.
	else:
		pass

		


