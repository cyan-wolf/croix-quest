extends Node2D

@onready var _loading_screen: Control = self.get_node("CanvasLayer/LoadingScreen")

func load_scene_file(scene_path: String) -> void:
	self.show_loading_screen()
	self.get_tree().change_scene_to_file(scene_path)

	# Show the loading screen while the scene is loading.
	# Hide it again after the scene has loaded.
	var callback: Callable = (func():
		await self.get_tree().tree_changed
		await self.async_delay(0.5)
		
		self.hide_loading_screen()
	)

	callback.call()


func load_packed_scene(scene: PackedScene) -> void:
	self.load_scene_file(scene.resource_path)


func find_player() -> Player:
	return self.get_tree().current_scene.get_node("Player") as Player


func find_camera() -> Camera2D:
	return self.get_viewport().get_camera_2d()


func async_delay(delay_in_secs: float) -> void:
	await self.get_tree().create_timer(delay_in_secs).timeout


func show_loading_screen() -> void:
	_loading_screen.show()


func hide_loading_screen() -> void:
	_loading_screen.hide()

