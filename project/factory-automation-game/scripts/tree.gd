extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.has_carrot = true
		queue_free()
	
	pass # Replace with function body.
