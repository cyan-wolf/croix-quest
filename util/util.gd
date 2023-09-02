extends Node
class_name Util

### TYPE DEFINITIONS ###

## Utility enum for keeping track of a character's direction.
enum Direction {
	RIGHT = 0,
	LEFT = 1,
}

## Utility enum for keeping track of a player's weapon.
enum WeaponType {
	GUN = 0,
	SHOTGUN = 1,
	SNIPER = 2,
	SMG = 3,
}

## Utility class for keeping track of status effects.
class StatusEffect:
	var type: StatusEffectType 
	var duration_in_secs: float = 60.0 # 1 minute

	func _init(type_: StatusEffectType, duration_in_secs_: float) -> void:
		self.type = type_
		self.duration_in_secs = duration_in_secs_


enum StatusEffectType {
	NONE = 0,
	SPEED = 1,
	DEFENSE = 2,
	NO_MANA_CONSUMPTION = 4,
}

### STATIC FUNCTION DEFINITIONS ###

## Returns an array of size `amount` containing unique random elements from `array`.
static func choose_random_elements_from_array(array: Array, amount: int) -> Array:
	var copied_array := array.duplicate() # shallow copy

	randomize()
	# Randomizes the order of a copy of the array.
	# Example: [1, 2, 3, 4] -> [2, 3, 1, 4]
	copied_array.shuffle()

	# Returns the first elements given by `amount`.
	# Example: If `amount` = 2, this function would return [2, 3]. 
	return copied_array.slice(0, amount)

