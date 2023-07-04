extends Button

@export_file("*.tscn") var _new_scene_file: String


func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	SceneManager.load_scene_file(_new_scene_file)

