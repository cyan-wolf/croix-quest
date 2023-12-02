extends AnimatableBody2D

# This rock cannot be moved, instead a dialog pops up telling the 
# player the futility of their actions.
@export var _cant_move_dialog: DialogResource

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	DialogManager.start_dialog(_cant_move_dialog)


func destroy() -> void:
	# TODO: Add a sound and particle effect.
	self.queue_free()


