extends CharacterBody2D

signal dialog_started
signal dialog_ended

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

@export var _animated_sprite: AnimatedSprite2D
@export var _dialog: DialogResource

func _ready() -> void:
	_interaction_component.interact.connect(_async_on_player_interact)
	_animated_sprite.play("idle")


func _async_on_player_interact() -> void:
	self.dialog_started.emit()
	DialogManager.start_dialog(_dialog)

	await DialogManager.ended_dialog

	self.dialog_ended.emit()

