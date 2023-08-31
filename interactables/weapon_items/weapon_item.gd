extends Node2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

@export var _weapon_type: Util.WeaponType

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	SceneManager.find_player().add_weapon_type(_weapon_type)
	self.queue_free()

