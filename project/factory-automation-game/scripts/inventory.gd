extends Node2D

var inventory: Array = []

var item_buttons: Array = []

func _ready() -> void:
	update_inventory_ui()

func add_item(item_data: Dictionary) -> void:
	inventory.append(item_data)
	update_inventory_ui()

func remove_item(item_index: int) -> void:
	if item_index >= 0 and item_index < inventory.size():
		inventory.remove_at(item_index)
		update_inventory_ui()

func update_inventory_ui() -> void:
	for button in item_buttons:
		button.queue_free()

	item_buttons.clear()

	for index in range(inventory.size()):
		var item = inventory[index]
		var button = Button.new()
		button.text = " "
		button.pressed.connect(Callable(self, "_on_item_button_pressed").bind(item, index))

		button.icon = item["image"]
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		
		$VBoxContainer.add_child(button)
		item_buttons.append(button)

func _on_item_button_pressed(item_data: Dictionary, item_index: int) -> void:
	var player = $"../Player"
	player.selected_item = item_data["item"]
	player.is_placing = true
	remove_item(item_index)
