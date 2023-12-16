extends Node
class_name Util

### CONSTANTS ###

## Namespace for the different scene paths.
class ScenePath:
	# Explorable areas.
	const HIDEOUT_HUB := "res://maps/hideout_hub/hideout_hub.tscn"
	const INTRO_CASTLE := "res://maps/intro_castle/intro_castle_map.tscn"
	const COBALT_DUNGEON := "res://maps/dungeons/cobalt_dungeon/cobalt_dungeon.tscn"
	const ULMUS_DUNGEON := "res://maps/dungeons/ulmus_dungeon/ulmus_dungeon.tscn"
	const VODOROD_DUNGEON := "res://maps/dungeons/vodorod_dungeon/vodorod_dungeon.tscn"
	const DUNKEL_DUNGEON := "res://maps/dungeons/dunkel_dungeon/dunkel_dungeon.tscn"

	# Boss scenes.
	const INTRO_CASTLE_FIGHT := "res://maps/intro_castle/boss_fight/queen_boss_fight.tscn"
	const COBALT_BOSS_FIGHT := "res://maps/dungeons/cobalt_dungeon/boss_fight/cobalt_dugeon_boss_fight.tscn"
	const ULMUS_BOSS_FIGHT := "res://maps/dungeons/ulmus_dungeon/boss_fight/ulmus_dungeon_boss_fight.tscn"
	const VODOROD_BOSS_FIGHT := "res://maps/dungeons/vodorod_dungeon/boss_fight/vodorod_dungeon_boss_fight.tscn"
	const DUNKEL_BOSS_FIGHT := "res://maps/dungeons/dunkel_dungeon/boss_fight/dunkel_dungeon_boss_fight.tscn"

	# Menus.
	const MAIN_MENU := "res://ui/menus/main_menu/main_menu.tscn"


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
}

## Utility enum for keeping track of the player's "milestones" in the game.
enum Milestone {
	NONE, 
	INTRO_CASTLE_COMPLETED,
	COBALT_DUNGEON_COMPLETED,
	ULMUS_DUNGEON_COMPLETED,
	VODOROD_DUNGEON_COMPLETED,
	DUNKEL_DUNGEON_COMPLETED,
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

	const NUM_REQUIRED_PROPERTIES := 4

	# Required properties
	var global_position: Vector2
	var impulse: Vector2		# speed + direction
	var source: Projectile.Source	# who (player or enemy) fired the projectile
	var damage: int

	# Optional properties
	var lifetime: float = 2.0	# in seconds
	var sprite_frames: SpriteFrames = Projectile.DEFAULT_PROJECTILE_SPRITE_FRAMES
	var is_able_to_pass_through_wall_edges: bool = false	# if true, it the projectile can go through the map
	var scale: float = 1.0		# determines the sprite and collision box's scale
	var trail_gradient: Gradient = Projectile.DEFAULT_PROJECTILE_TRAIL_GRADIENT # determines the trail colors

	# A hash set for keeping track if all required properties have been set.
	var _required_properties_set := {}

	func with_global_pos(global_position_: Vector2) -> ProjectileBuilder:
		_mark_required_property_as_set("global_position")
		self.global_position = global_position_
		return self


	func with_impulse(impulse_: Vector2) -> ProjectileBuilder:
		_mark_required_property_as_set("impulse")
		self.impulse = impulse_
		return self

	
	func from_source(source_: Projectile.Source) -> ProjectileBuilder:
		_mark_required_property_as_set("source")
		self.source = source_
		return self


	func with_damage(damage_: int) -> ProjectileBuilder:
		_mark_required_property_as_set("damage")
		damage = damage_
		return self

	
	func with_lifetime(lifetime_in_secs: float) -> ProjectileBuilder:
		self.lifetime = lifetime_in_secs
		return self

	
	func with_sprite_frames(sprite_frames_: SpriteFrames) -> ProjectileBuilder:
		self.sprite_frames = sprite_frames_
		return self


	func can_pass_through_wall_edges(yes_or_no: bool) -> ProjectileBuilder:
		self.is_able_to_pass_through_wall_edges = yes_or_no
		return self


	func with_scale(scale_: float) -> ProjectileBuilder:
		self.scale = scale_
		return self


	func with_trail_gradient(gradient: Gradient) -> ProjectileBuilder:
		self.trail_gradient = gradient
		return self


	## Finishes the creation of the projectile. This function only returns the created projectile, 
	## it does not add it to the scene, for that, use `.add_to_scene()` instead.
	func create() -> Projectile:
		var projectile: Projectile = PROJECTILE_SCENE.instantiate()

		if not _all_required_properties_have_been_set():
			print_debug("ERROR: Not all required properties have been set in projectile initialization")

		# Use the builder fields to initialize the projectile's fields 
		projectile.initialize_using_builder(self)
 
		return projectile


	## Convenience function to be used intstead of `.create()` to create the projectile and add it to the scene.
	func add_to_scene() -> void:
		var projectile := self.create()
		SceneManager.get_tree().get_root().add_child(projectile)


	func _mark_required_property_as_set(prop_name: String) -> void:
		# This is a hash set so the value isn't important.
		_required_properties_set[prop_name] = null


	func _all_required_properties_have_been_set() -> bool:
		return len(_required_properties_set) == NUM_REQUIRED_PROPERTIES

