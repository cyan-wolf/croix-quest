extends Node
class_name Util

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

