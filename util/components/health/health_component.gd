extends Resource
class_name HealthComponent

signal health_changed
signal death

@export var _health: int = 8

var _max_health: int = _health # wrong value, the correct value is set using `_set_max_health_if_unset()`
var _max_health_has_been_set := false

func get_health() -> int:
	# Required because Godot won't let me use `_ready()` in a `Resource`.
	_set_max_health_if_unset()

	return _health


func get_max_health() -> int:
	# Required because Godot won't let me use `_ready()` in a `Resource`.
	_set_max_health_if_unset()

	return _max_health


func take_damage(amount: int) -> void:
	# Required because Godot won't let me use `_ready()` in a `Resource`.
	_set_max_health_if_unset()

	# Takes damage.
	if amount < _health:
		_health -= amount
		self.health_changed.emit()
	
	# If the blow is fatal, emit the `death` signal (only emitted once).
	elif not self.is_dead():
		_health = 0
		self.health_changed.emit()
		self.death.emit()

	# Do nothing if `self` takes damage while already dead.
	else:
		pass


func is_dead() -> bool:
	return _health == 0


func gain_health(amount: int) -> void:
	# Required because Godot won't let me use `_ready()` in a `Resource`.
	_set_max_health_if_unset()

	_health = clampi(_health + amount, 0, _max_health)
	self.health_changed.emit()


# Initializes `_max_health` AT RUN TIME. This is necessary since the 
# "var" initializer runs at "static" time, meaning `_max_health` always gets 
# set to the default `_health` value otherwise.
func _set_max_health_if_unset() -> void:
	if not _max_health_has_been_set:
		_max_health = _health
		_max_health_has_been_set = true

