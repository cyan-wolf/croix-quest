extends Resource
class_name HealthComponent

signal health_changed
signal death

@export var _health: int = 8

var _max_health = _health

func get_health() -> int:
	return _health


func take_damage(amount: int) -> void:
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
	_health = clampi(_health + amount, 0, _max_health)
	self.health_changed.emit()

