extends Node2D

const DialogNpc := preload("res://npcs/dialog_npc/dialog_npc.gd")

@onready var _emmy_dialog_npc: DialogNpc = self.get_node("../EmmyDialogNPC")

func _ready() -> void:
	_emmy_dialog_npc.dialog_ended.connect(_on_emmy_dialog_ended)


func _on_emmy_dialog_ended() -> void:
	# Once Emmy has explained the lore, go to the hub of the game.
	SceneManager.load_scene_file("res://maps/hideout_hub/hideout_hub.tscn")

