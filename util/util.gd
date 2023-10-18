extends Node
class_name Util

const Projectile := preload("res://weapons/projectile/projectile.gd")

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

## Utility enum for keeping track of an enemy's state.
enum EnemyState {
	IDLE = 0,
	FOLLOWING = 1,
	ATTACKING = 2,
}

## Utility enum for keeping track of whether a cutscene is playing,
## the loading screen is visible, etc.
enum WorldState {
	NONE = 0, # this state is unused, but it could be useful
	CUTSCENE_PLAYING = 1,
	DIALOG_PLAYING = 2,
	LOADING_SCREEN_VISIBLE = 3,
	PLAYER_IS_DEAD = 4,
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
	NO_MANA_CONSUMPTION = 4, # unused
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


## Returns `true` depending on `probability`.
## Example: If `probability` is 0.45, then this returns `true` 45% of the time.
static func return_true_given_probability(probability: float) -> bool:
	randomize()
	return randf() < probability


class ProjectileBuilder:
	const PROJECTILE_SCENE := preload("res://weapons/projectile/projectile.tscn")

	# Required properties
	var _global_position: Vector2
	var _impulse: Vector2		# speed + direction
	var _source: Projectile.Source	# who (player or enemy) fired the projectile
	var _damage: int

	# Optional properties
	var _lifetime: float = 2.0	# in seconds
	var _sprite_frames: SpriteFrames = Projectile.DEFAULT_PROJECTILE_SPRITE_FRAMES
	var _can_pass_through_wall_edges: bool = false	# if true, it the projectile can go through the map
	var _scale: float = 1.0		# determines the sprite and collision box's scale

	func with_global_pos(global_pos: Vector2) -> ProjectileBuilder:
		_global_position = global_pos
		return self


	func with_impulse(impulse: Vector2) -> ProjectileBuilder:
		_impulse = impulse
		return self

	
	func from_source(source: Projectile.Source) -> ProjectileBuilder:
		_source = source
		return self


	func with_damage(damage: int) -> ProjectileBuilder:
		_damage = damage
		return self

	
	func with_lifetime(lifetime_in_secs: float) -> ProjectileBuilder:
		_lifetime = lifetime_in_secs
		return self

	
	func with_sprite_frames(sprite_frames: SpriteFrames) -> ProjectileBuilder:
		_sprite_frames = sprite_frames
		return self


	func can_pass_through_wall_edges(yes_or_no: bool) -> ProjectileBuilder:
		_can_pass_through_wall_edges = yes_or_no
		return self


	func with_scale(scale: float) -> ProjectileBuilder:
		_scale = scale
		return self


	func instantiate() -> Projectile:
		var projectile: Projectile = PROJECTILE_SCENE.instantiate()

		# TODO: Use the builder fields to initialize the projectile's fields 
		# (damage, impulse, can_pass_through_wall_edges, etc.) ...

		return projectile

