extends CharacterBody2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

@export var _animated_sprite: AnimatedSprite2D
@export var _dialog: DialogResource

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)
	_animated_sprite.play("idle")


func _on_player_interact() -> void:
	DialogManager.start_dialog(_dialog)

