extends CharacterBody2D

const SPEED = 250.0

var target_position: Vector2 = Vector2.ZERO
var current_axis: String = ""
var last_direction: int = 1

var selected_item: Resource = null
var is_placing: bool = false
var is_in_inventory: bool = false

var is_moving: bool = false

@onready var inventory_ui = $"../inventory"

func _physics_process(delta: float) -> void:
	if not is_placing and not is_in_inventory:
		if current_axis:
			# Move horizontally
			if current_axis == "x" and abs(target_position.x - global_position.x) > 5.0:
				var direction = sign(target_position.x - global_position.x)
				velocity = Vector2(direction * SPEED, 0)
				flip_axis(direction)
				is_moving = true
			# Move vertically
			elif current_axis == "y" and abs(target_position.y - global_position.y) > 5.0:
				velocity = Vector2(0, sign(target_position.y - global_position.y) * SPEED)
				is_moving = true
			else:
				_switch_axis()
		else:
			velocity = Vector2.ZERO
			is_moving = false
		
		if is_moving:
			$AnimationTree['parameters/conditions/idle'] = false
			$AnimationTree['parameters/conditions/walk'] = true
		else:
			$AnimationTree['parameters/conditions/walk'] = false
			$AnimationTree['parameters/conditions/idle'] = true
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		$AnimationTree['parameters/conditions/walk'] = false
		$AnimationTree['parameters/conditions/idle'] = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if is_placing and selected_item:
			# Place the selected item
			_place_item_at(event.position)
			is_placing = false
			selected_item = null
		elif not is_placing and not is_in_inventory:
			# Set target position for movement
			target_position = event.position
			current_axis = "x" if abs(target_position.x - global_position.x) > abs(target_position.y - global_position.y) else "y"
	elif event is InputEventKey:
		if event.keycode == KEY_E and event.pressed:
			_toggle_inventory()

func _switch_axis() -> void:
	if current_axis == "x" and abs(target_position.y - global_position.y) > 5.0:
		current_axis = "y"
	elif current_axis == "y" and abs(target_position.x - global_position.x) > 5.0:
		current_axis = "x"
	else:
		current_axis = ""
		velocity = Vector2.ZERO

func flip_axis(direction: int) -> void:
	if direction != last_direction:
		scale.x = -scale.x
		last_direction = direction

# This function now delegates adding items to the inventory UI
func add_to_inventory(item_data: Dictionary) -> void:
	if inventory_ui:
		match item_data["name"]:
			"Carrot":
				item_data = {
					"name": item_data["name"],
					"image": item_data["image"],
					"item": $"../items".carrot
				}
			"Potato":
				item_data = {
					"name": item_data["name"],
					"image": item_data["image"],
					"item": $"../items".potato
				}
		inventory_ui.add_item(item_data)
	else:
		push_error("Inventory UI not found!")

# Toggle the visibility of the inventory
func _toggle_inventory() -> void:
	if inventory_ui:
		inventory_ui.visible = !inventory_ui.visible
		is_in_inventory = !is_in_inventory

func _place_item_at(position: Vector2) -> void:
	if selected_item:
		var item_instance = selected_item.instantiate()
		$"../items".add_child(item_instance)
		item_instance.position = position
		var item_index = inventory_ui.inventory.find(selected_item)

		if item_index != -1:
			inventory_ui.remove_item(item_index)
