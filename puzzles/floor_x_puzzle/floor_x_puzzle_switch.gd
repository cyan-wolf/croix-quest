extends Node2D

enum FloorSwitchState {
	OFF = 0,
	ON = 1,
	COMPLETE = 2,
}

signal activated
signal deactivated

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

var _state := FloorSwitchState.OFF

func _ready() -> void:
	_hitbox.body_entered.connect(_on_body_entered_hitbox)


# This hitbox needs to collide with the player's ground collision, not the regular hitbox.
func _on_body_entered_hitbox(other_hitbox: Node2D) -> void:	
	if other_hitbox.is_in_group("player_physics_body_collision"):
		_toggle_state()


func _toggle_state() -> void:
	match _state:
		FloorSwitchState.OFF:
			_state = FloorSwitchState.ON
			self.activated.emit()

		FloorSwitchState.ON:
			_state = FloorSwitchState.OFF
			self.deactivated.emit()

		FloorSwitchState.COMPLETE:
			pass

	_update_sprite()


func _update_sprite() -> void:
	var animation: String = ""

	match _state:
		FloorSwitchState.OFF:
			animation = "off"

		FloorSwitchState.ON:
			animation = "on"

		FloorSwitchState.COMPLETE:
			animation = "complete"

	_sprite.play(animation)


# Called by the puzzle script.
func force_deactivate() -> void:
	_state = FloorSwitchState.OFF
	self.deactivated.emit()
	_update_sprite()


# Called by the puzzle script.
func finish() -> void:
	_state = FloorSwitchState.COMPLETE
	_update_sprite()


