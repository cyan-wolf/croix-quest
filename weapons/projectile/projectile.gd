extends RigidBody2D

signal projectile_hit

var lifetime: float = 0.0
var damage: int = 0

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

func _ready():
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	_hitbox.body_entered.connect(_on_body_entered_hitbox)
	self.projectile_hit.connect(_on_projectile_hit)

	# Despawn the projectile if it doesn't hit anything by this point.
	await self.get_tree().create_timer(lifetime).timeout
	self.queue_free()


# This is supposed to destroy the projectile if it hits an enemy.
func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("enemy_hitbox"):
		self.projectile_hit.emit()


# This is supposed to destroy the projectile if it hits the "edge" of the dungeon.
func _on_body_entered_hitbox(_body: Node2D) -> void:
	self.projectile_hit.emit()


# TODO: Add an animation or particle effect when the projectile hits something and gets destroyed.
func _on_projectile_hit() -> void:
	self.queue_free()

