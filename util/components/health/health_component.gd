extends Resource
class_name HealthComponent

signal health_changed
signal death

@export var health: int = 8

func take_damage(amount: int) -> void:
	if amount < self.health:
		self.health -= amount
		self.health_changed.emit()
	
	elif not self.is_dead():
		self.health = 0
		self.health_changed.emit()
		self.death.emit()

	else:
		pass


func is_dead() -> bool:
	return self.health == 0


