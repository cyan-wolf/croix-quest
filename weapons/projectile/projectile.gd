extends RigidBody2D

enum Source {
	PLAYER = 0,
	ENEMY = 1,
	QUEEN_BOSS = 2,
}

signal projectile_hit

# Default values
var _lifetime: float = 0.0
var _damage: int = 0
## Indicates "who" shot the projectile.
var _source: Source = Source.PLAYER

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready():
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	_hitbox.body_entered.connect(_on_body_entered_hitbox)
	self.projectile_hit.connect(_on_projectile_hit)

	# Despawn the projectile if it doesn't hit anything by this point.
	await self.get_tree().create_timer(_lifetime).timeout
	self.queue_free()


# This is supposed to destroy the projectile if it hits an enemy.
func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	match _source:
		Source.PLAYER:
			if other_hitbox.is_in_group("enemy_hitbox"):
				self.projectile_hit.emit()

		_:
			if other_hitbox.is_in_group("player_hitbox"):
				self.projectile_hit.emit()


# This is supposed to destroy the projectile if it hits the "edge" of the dungeon.
func _on_body_entered_hitbox(_body: Node2D) -> void:
	self.projectile_hit.emit()


# TODO: Add an animation or particle effect when the projectile hits something and gets destroyed.
func _on_projectile_hit() -> void:
	self.queue_free()


## Must be called before adding the projectile to the scene tree.
func initialize(global_pos: Vector2, 
		sprite_rotation: float, 
		lifetime: float, 
		damage: int, 
		source: Source,
		impulse: Vector2) -> void:
	# Initialize important fields.
	self.global_position = global_pos
	self.rotation = sprite_rotation
	_lifetime = lifetime
	_damage = damage
	_source = source

	# Make the projectile move in this direction (not affected by `self.rotation`).
	self.apply_impulse(impulse)


func get_damage() -> int:
	return _damage


func get_source() -> Source:
	return _source


func is_from_player() -> bool:
	return _source == Source.PLAYER

