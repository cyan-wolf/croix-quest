extends CharacterBody2D

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@export var _dialog: DialogResource

var _can_be_interacted_with := false

func _ready() -> void:
	self.input_event.connect(_on_input_event)
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	_hitbox.area_exited.connect(_on_area_exited_hitbox)


# FIXME: Figure out why this node doesn't register mouse clicks.
# (this node should start a dialog if clicked on by the mouse when the player is nearby)
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		if _can_be_interacted_with:
			DialogManager.start_dialog(_dialog)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		_can_be_interacted_with = true


func _on_area_exited_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("player_hitbox"):
		_can_be_interacted_with = false

