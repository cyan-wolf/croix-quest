extends Resource
class_name HealthComponent

signal health_changed
signal death

@export var health: int = 8

func take_damage(amount: int) -> void:
	# Takes damage.
	if amount < self.health:
		self.health -= amount
		self.health_changed.emit()
	
	# If the blow is fatal, emit the `death` signal (only emitted once).
	elif not self.is_dead():
		self.health = 0
		self.health_changed.emit()
		self.death.emit()

	# Do nothing if `self` takes damage while already dead.
	else:
		pass


func is_dead() -> bool:
	return self.health == 0


