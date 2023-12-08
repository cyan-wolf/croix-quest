extends Node2D

signal activated

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

var _has_been_used := false

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		if not _has_been_used:
			_sprite.play("activated")
			_has_been_used = true
			self.activated.emit()


## Returns `true` if this checkpoint has been used before.
func has_been_used_before() -> bool:
	return _has_been_used

