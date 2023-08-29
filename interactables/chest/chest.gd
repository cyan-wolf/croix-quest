extends Node2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")
@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

## The items that this chest will drop when opened.
@export var _contents: Array[PackedScene] = []

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)


func _on_player_interact() -> void:
	# TODO: Play some chest opening sound here.
	_sprite.play("open")

	await SceneManager.async_delay(0.6)

	for item_scene in _contents:
		var item_node: Node2D = item_scene.instantiate()

		# Generate the item at the chest's position + some random offset.
		var item_spawn_position := self.global_position + Vector2(_gen_random_offset(), _gen_random_offset() / 4)

		item_node.global_position = item_spawn_position

		self.get_tree().current_scene.add_child(item_node)

	self.queue_free()


func _gen_random_offset() -> int:
	randomize()
	return randi_range(-16, 16)

