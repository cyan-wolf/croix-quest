extends Node2D

func load_scene_file(scene_path: String) -> void:
	self.get_tree().change_scene_to_file(scene_path)


func load_packed_scene(scene: PackedScene) -> void:
	self.get_tree().change_scene_to_packed(scene)

