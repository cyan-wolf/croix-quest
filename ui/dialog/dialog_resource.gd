extends Resource
class_name DialogResource

@export var author: String = "Placeholder"
@export_multiline var dialog: Array[String] = []

static func create(author_: String, dialog_: Array[String]) -> DialogResource:
	var new_dialog_res := DialogResource.new()

	new_dialog_res.author = author_
	new_dialog_res.dialog = dialog_

	return new_dialog_res

