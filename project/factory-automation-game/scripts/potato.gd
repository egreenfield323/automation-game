extends Node2D

var item_data: Dictionary = {}
@export var image: Texture

func _ready():
	item_data = {
		"name": "Potato",
		"image": image,
	}

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if item_data:
			body.add_to_inventory(item_data)
		else:
			push_error("Item did not have any data")
		queue_free()
