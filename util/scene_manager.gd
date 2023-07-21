extends Node2D

func load_scene_file(scene_path: String) -> void:
	self.get_tree().change_scene_to_file(scene_path)


func load_packed_scene(scene: PackedScene) -> void:
	self.get_tree().change_scene_to_packed(scene)


func find_player() -> Player:
	return self.get_tree().current_scene.get_node("Player") as Player


func find_camera() -> Camera2D:
	return self.get_viewport().get_camera_2d()

