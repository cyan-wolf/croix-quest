extends CharacterBody2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

@export var health_component: HealthComponent

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
@onready var _queen_sprite: AnimatedSprite2D = self.get_node("QueenCroixNPCSprite")

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.health_component.death.connect(_on_defeat)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()
		self.health_component.take_damage(projectile.damage)


# TODO: The Queen is defeated, but she just heals herself using magic and defeats you.
func _on_defeat() -> void:
	# Temporary debug stuff: 
	print_debug("You won...?")
	_queen_sprite.flip_h = true

