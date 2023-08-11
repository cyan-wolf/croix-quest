extends Resource
class_name ManaComponent

signal mana_amount_changed

const MAX_MANA := 4

@export var _mana_amount: int = 4

func get_mana_amount() -> int:
	return _mana_amount


# This function should be used before trying to perform any spells.
func has_enough_mana(amount: int) -> bool:
	return _mana_amount >= amount


# Consumes mana.
func use_mana(amount: int) -> void:
	# Makes sure that the `_mana_amount` is always between 0 and `MAX_MANA`.
	_mana_amount = clampi(_mana_amount - amount, 0, MAX_MANA)

	self.mana_amount_changed.emit()


func gain_mana(amount: int) -> void:
	var new_mana_amount := _mana_amount + amount

	if new_mana_amount <= MAX_MANA:
		_mana_amount = new_mana_amount

		self.mana_amount_changed.emit()

