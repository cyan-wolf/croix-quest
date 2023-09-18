extends Node2D

@onready var _dungeon_selector_ui: Control = self.get_node("CanvasLayer/DungeonSelectorUI")

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)
	_dungeon_selector_ui.hide()


func _on_player_interact() -> void:
	# Shows the dungeon selection UI when the player clicks on the dungeon selector manager.
	_dungeon_selector_ui.show()


func _setup_buttons() -> void:
	# TODO: Conenct signals to the buttons that teleport the player to their corresponding dungeon.
	# Keep track of what dungeons the player is allowed to visit (the player can only visit 
	# 'Cobalt Dungeon' at the start and can only visit 'Castle' at the end (for the final boss)).
	pass

