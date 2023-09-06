extends Node2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

signal hit

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

var _activated := false

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player() and not _activated:
			_sprite.play("partial")
			_activated = true
			self.hit.emit()


# Happens when the door associated with this switch opens.
# This function is called by the door.
func complete_activation() -> void:
	_sprite.play("complete")
