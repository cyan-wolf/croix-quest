extends Resource
class_name ManaComponent

signal mana_amount_changed

const MAX_MANA := 4

@export var mana_amount: int = 4

# This function should be used before trying to perform any spells.
func has_enough_mana(amount: int) -> bool:
	return self.mana_amount >= amount


# Consumes mana.
func use_mana(amount: int) -> void:
	# Makes sure that the `mana_amount` is always between 0 and `MAX_MANA`.
	self.mana_amount = clampi(self.mana_amount - amount, 0, MAX_MANA)

	self.mana_amount_changed.emit()


