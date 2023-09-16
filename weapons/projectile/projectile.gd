extends RigidBody2D

# This isn't set with `@onready` because it seems like `initialize()` runs first.
var _sprite: AnimatedSprite2D

const DEFAULT_PROJECTILE_SPRITE_FRAMES := preload("res://weapons/projectile/default_projectile_sprite_frames.tres")

var _bullet_particle_emitter_scene = preload("res://particles/bullet_impact.tscn")

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
		# Projectile was fired by the player.
		Source.PLAYER:
			# Happens when the projectile hits an enemy (or a boss).
			if other_hitbox.is_in_group("enemy_hitbox"):
				self.projectile_hit.emit()

			# Happens when the projectile hits something like a projectile-activated switch.
			if other_hitbox.is_in_group("projectile_interactable_hitbox"):
				self.projectile_hit.emit()

		# Projectile was fired by someone else.
		_:
			if other_hitbox.is_in_group("player_hitbox"):
				self.projectile_hit.emit()


# This is supposed to destroy the projectile if it hits the "edge" of the dungeon.
func _on_body_entered_hitbox(_body: Node2D) -> void:
	self.projectile_hit.emit()


# TODO: Add an animation or particle effect when the projectile hits something and gets destroyed.
func _on_projectile_hit() -> void:
	var coords = self.position
	var impact_particles: GPUParticles2D = _bullet_particle_emitter_scene.instantiate()
	impact_particles.emitting = true
	impact_particles.position = coords
	self.get_tree().get_root().add_child(impact_particles)

	# Run this function asynchronously.
	_async_remove_particles_after_delay(impact_particles)

	self.queue_free()


## Must be called before adding the projectile to the scene tree.
func initialize(global_pos: Vector2, 
		# How long it takes for it to despawn.
		lifetime: float,
		# 1 damage is the same as 1/2 heart.							
		damage: int,
		# Whether the player or an enemy fired it.					
		source: Source,
		# The direction times the speed of the projectile.						
		impulse: Vector2,
		# The sprite frames of the projectile; if null, the default sprite is used.
		projectile_sprite_frames: SpriteFrames = null,
	) -> void:

	# Initialize important fields.
	self.global_position = global_pos
	self.rotation = impulse.angle()
	_lifetime = lifetime
	_damage = damage
	_source = source

	# Make the projectile move in this direction (not affected by `self.rotation`).
	self.apply_impulse(impulse)

	# Set `_sprite` here because this function runs before `_ready()`.
	_sprite = self.get_node("AnimatedSprite2D")

	if projectile_sprite_frames != null:
		_sprite.sprite_frames = projectile_sprite_frames

	else:
		_sprite.sprite_frames = DEFAULT_PROJECTILE_SPRITE_FRAMES

	# Play whatever animation was provided by the sprite frames.
	_sprite.play("default")


func get_damage() -> int:
	return _damage


func get_source() -> Source:
	return _source


func is_from_player() -> bool:
	return _source == Source.PLAYER


func _async_remove_particles_after_delay(particles: GPUParticles2D) -> void:
	await SceneManager.async_delay(5.0)
	particles.queue_free()

