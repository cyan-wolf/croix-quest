extends Node2D


func _ready():
	_connect_npc_reaction_dialog_signals()


# Connects puzzle completion signals to update NPC dialogs accordingly.
func _connect_npc_reaction_dialog_signals() -> void:
	self.get_node("../PropCollection/PuzzleCollection/FloorXPuzzle") \
		.completed \
		.connect(func(): 
			var dialog_npc = self.get_node("../PropCollection/NpcCollection/PuzzlemasterDialogNPC")
			
			dialog_npc.set_dialog(DialogResource.create("Puzzlemaster", [
				"...", 
				"How...?", 
			]))
			)

	self.get_node("../PropCollection/PuzzleCollection/FloorXPuzzle2") \
		.completed \
		.connect(func(): 
			var dialog_npc = self.get_node("../PropCollection/NpcCollection/PuzzleDialogNPC")
			
			dialog_npc.set_dialog(DialogResource.create("Puzzlemaster", [
				"...", 
				"Impossible...", 
			]))
			)

	self.get_node("../PropCollection/PuzzleCollection/FloorXPuzzle3") \
		.completed \
		.connect(func(): 
			var dialog_npc = self.get_node("../PropCollection/NpcCollection/PuzzlemasterNPC")
			
			dialog_npc.set_dialog(DialogResource.create("Puzzlemaster", [
				"...", 
			]))
			)

	self.get_node("../PropCollection/PuzzleCollection/FloorXPuzzle4") \
		.completed \
		.connect(func(): 
			var dialog_npc = self.get_node("../PropCollection/NpcCollection/PuzzleMasterDialogNPC")
			
			dialog_npc.set_dialog(DialogResource.create("Puzzlemaster", [
				"...",
				"That's it. I'm gonna dramatically storm off.",
				"I'm extremely fast, so you won't be able to see me storm off, but still. It'll be dramatic.",
				"So, bye.",
			]))

			dialog_npc.dialog_ended.connect(func():
				await SceneManager.async_delay(0.2) 
				# Make the Puzzlemaster go away dramatically.
				dialog_npc.global_position -= Vector2.UP * 16 * 999999
			)

			)

