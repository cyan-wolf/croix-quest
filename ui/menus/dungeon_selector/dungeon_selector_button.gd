extends TextureButton

@export_file("*.tscn") var _dungeon_scene_file: String

@export var _required_milestone: Util.Milestone = Util.Milestone.NONE

func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if SceneManager.progression().has_milestone(_required_milestone):
		SceneManager.load_scene_file(_dungeon_scene_file)

