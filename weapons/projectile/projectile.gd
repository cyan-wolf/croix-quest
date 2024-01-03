extends RigidBody2D
class_name Projectile

const SpriteFramesConsts := preload("res://weapons/projectile/sprite_frames/projectile_sprite_frames.gd")
const TrailConsts := preload("res://weapons/projectile/projectile_trails/projectile_trails.gd")

# These aren't set with `@onready`, because the projectile initialization code is run before it gets 
# added to the scene.
var _sprite: AnimatedSprite2D
var _trail: Line2D

var _bullet_particle_emitter_scene = preload("res://particles/bullet_impact.tscn")

enum Source {
	PLAYER = 0,
	ENEMY = 1,
	QUEEN_BOSS = 2,
	TAURON_BOSS = 3,
	PAUL_BOSS = 4,
	SHALE_SABER_BOSS = 5,
	ASTRAL_LINEUS_BOSS = 6,
}

signal projectile_hit

# Default values
var _lifetime: float = 0.0
var _damage: int = 0
## Indicates "who" shot the projectile.
var _source: Source = Source.PLAYER

## Indicates the scale of the projectile relative to the current sizes on the scene.
var _scale: float = 1.0

## Indicates whether the projectile collides with the edges of the map.
var _collides_with_wall_edges := true

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready():
	# Connect signals.
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	_hitbox.body_entered.connect(_on_body_entered_hitbox)
	self.projectile_hit.connect(_on_projectile_hit)

	# Adjust the projectile's physical scale according to its `_scale` property.
	_set_sprite_and_collision_scale()


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
func _on_body_entered_hitbox(tile: Node2D) -> void:
	if _collides_with_wall_edges and not tile.is_in_group("slippery_floor_tile_hitbox"):
		self.projectile_hit.emit()


func _on_projectile_hit() -> void:
	var coords = self.position
	var impact_particles: GPUParticles2D = _bullet_particle_emitter_scene.instantiate()
	impact_particles.emitting = true
	impact_particles.position = coords
	self.get_tree().get_root().add_child(impact_particles)

	# Run this function asynchronously.
	_async_remove_particles_after_delay(impact_particles)

	self.queue_free()


func get_damage() -> int:
	return _damage


func get_source() -> Source:
	return _source


func is_from_player() -> bool:
	return _source == Source.PLAYER


func _async_remove_particles_after_delay(particles: GPUParticles2D) -> void:
	await SceneManager.async_delay(5.0)
	particles.queue_free()


func _set_sprite_and_collision_scale() -> void:
	var rigid_body_col: CollisionShape2D = self.get_node("CollisionShape2D")
	var hitbox_col: CollisionShape2D = self.get_node("HitboxArea/CollisionShape2D2")

	# Make the `shape` properties unique (they aren't unique by default for some reason).
	rigid_body_col.shape = rigid_body_col.shape.duplicate(true)
	hitbox_col.shape = rigid_body_col.shape.duplicate(true)

	# Apply the scale to the radii of the rigidbody and hitbox.
	rigid_body_col.shape.radius *= _scale
	hitbox_col.shape.radius *= _scale

	# Apply the scale to the sprite by calculating an equivalent scale for it.
	var adjusted_sprite_scale: float = hitbox_col.shape.radius / 8.0
	_sprite.scale = Vector2(adjusted_sprite_scale, adjusted_sprite_scale)


## The canonical way of creating a projectile.
static func start_building() -> Util.ProjectileBuilder:
	return Util.ProjectileBuilder.new()


## This is a helper method, use `Projectile.start_building()` instead.
func initialize_using_builder(builder: Util.ProjectileBuilder)  -> void:
	# Initialize important fields.
	self.global_position = builder.global_position
	self.rotation = builder.impulse.angle()
	_lifetime = builder.lifetime
	_damage = builder.damage
	_source = builder.source

	# Make the projectile move in this direction (not affected by `self.rotation`).
	self.apply_impulse(builder.impulse)

	# Set `_sprite` here because this function runs before `_ready()`.
	_sprite = self.get_node("AnimatedSprite2D")

	# Set '_trail' here for the same reason.
	_trail = self.get_node("ProjectileTrail")

	# Store the scale for now; the actual scale is applied when `_ready()` runs.
	_scale = builder.scale

	_sprite.sprite_frames = builder.sprite_frames.duplicate(true)

	_trail.gradient = builder.trail_gradient.duplicate(true)

	_collides_with_wall_edges = not builder.is_able_to_pass_through_wall_edges

	# Play whatever animation was provided by the sprite frames.
	_sprite.play("default")

