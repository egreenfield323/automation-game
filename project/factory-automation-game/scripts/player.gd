extends CharacterBody2D

const SPEED = 250.0

var target_position: Vector2 = Vector2.ZERO
var current_axis: String = ""
var last_direction: int = 1

var has_carrot = false
var is_moving = false

@export var carrot: Resource

func _physics_process(delta: float) -> void:
	if not has_carrot:
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
		if not has_carrot:
			target_position = event.position
			current_axis = "x" if abs(target_position.x - global_position.x) > abs(target_position.y - global_position.y) else "y"
		elif has_carrot:
			has_carrot = false
			_place_carrot_at(event.position)
			current_axis = ""
			target_position = global_position

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

func _enter_carrot_mode():
	has_carrot = true
	$AnimationTree['parameters/conditions/walk'] = false
	$AnimationTree['parameters/conditions/idle'] = true

func _place_carrot_at(position: Vector2) -> void:
	var carrot_instance = carrot.instantiate()
	get_parent().add_child(carrot_instance)
	carrot_instance.position = position
