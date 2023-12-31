extends Resource
class_name ManaComponent

# Fired when the mana amount changes.
signal mana_amount_changed
# Fired when the player runs out of mana.
signal ran_out_of_mana

const MAX_MANA := 4

@export var _mana_amount: int = 4

func get_mana_amount() -> int:
	return _mana_amount


# This function should be used before trying to perform any spells.
func has_enough_mana(amount: int) -> bool:
	return _mana_amount >= amount


# Consumes mana.
func use_mana(amount: int) -> void:
	# Don't run the code below again if the player already has 0 mana.
	if _mana_amount == 0:
		return

	# Makes sure that the `_mana_amount` is always between 0 and `MAX_MANA`.
	_mana_amount = clampi(_mana_amount - amount, 0, MAX_MANA)

	self.mana_amount_changed.emit()

	# Fires a signal if the player runs out of mana because of the above code.
	if _mana_amount == 0:
		self.ran_out_of_mana.emit()


func gain_mana(amount: int) -> void:
	_mana_amount = clampi(_mana_amount + amount, 0, MAX_MANA)
	self.mana_amount_changed.emit()

