extends HSlider

@export var _bus_name: String

var _bus_index: int

func _ready() -> void:
	_bus_index = AudioServer.get_bus_index(_bus_name)
	self.value_changed.connect(_on_value_changed)

	# Update the slider `value` with the current value on the audio server.
	self.value = db_to_linear(
		AudioServer.get_bus_volume_db(_bus_index)
	)


func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(
		_bus_index, 
		linear_to_db(new_value) # `self.value` is always equal to `new_value` here
	)

