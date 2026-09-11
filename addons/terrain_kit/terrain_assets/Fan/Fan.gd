@tool
@icon("fan.svg")
extends PropOrHazard
class_name Fan

enum AIR_DIR \
{
	## Air pushes the body that entered it's [member Fan.air_area] up.
	UP,
	## Air pushes the body that entered it's [member Fan.air_area] down.
	DOWN,
	## Air pushes the body that entered it's [member Fan.air_area] left.
	LEFT,
	## Air pushes the body that entered it's [member Fan.air_area] right.
	RIGHT
}

@export_category("Fan Essentials")
## The Area2D that covers the piece of land the [u]Fan[/u] is hitting.
@export var air_area:Area2D
## In which direction the [u]Fan[/u] is pushing the bodies that air is hitting.
@export var direction_of_air:AIR_DIR = AIR_DIR.UP
## Force of the air.
@export_range(0.0, 5000.0, 10.0, "or_greater", "hide_control") var force: float = 1500.0
## A value that is reducing the force for objects that have no [b]gravity[/b] (e.g. [Area2D]).
@export_range(0.001, 1.0, 0.01, "prefer_slider")var non_physics_dampener: float = 0.15 

var _bodies_in_air:Array[CollisionObject2D] = []
var _dir_of_air:Vector2

func _from_start() -> void:
	_calculate_air_direction() # Calculate exactly once at startup.
	
	# 1. Detect Bodies (Player, Crates)
	if not air_area.body_entered.is_connected(_on_body_entered_air):
		air_area.body_entered.connect(_on_body_entered_air)
	if not air_area.body_exited.is_connected(_on_body_exited_air):
		air_area.body_exited.connect(_on_body_exited_air)
		
	# 2. Detect Areas (Fireballs, Hitboxes)
	if not air_area.area_entered.is_connected(_on_body_entered_air):
		air_area.area_entered.connect(_on_body_entered_air)
	if not air_area.area_exited.is_connected(_on_body_exited_air):
		air_area.area_exited.connect(_on_body_exited_air)

func _calculate_air_direction() -> void:
	match direction_of_air:
		AIR_DIR.UP: _dir_of_air = Vector2.UP
		AIR_DIR.DOWN: _dir_of_air = Vector2.DOWN
		AIR_DIR.LEFT: _dir_of_air = Vector2.LEFT
		AIR_DIR.RIGHT: _dir_of_air = Vector2.RIGHT

func _on_body_entered_air(body: Node2D) -> void:
	if body is CollisionObject2D and not body == self:
		_bodies_in_air.append(body)

func _on_body_exited_air(body: Node2D) -> void:
	if _bodies_in_air.has(body):
		_bodies_in_air.erase(body)

func _physics_update(delta: float) -> void:
	if _bodies_in_air.is_empty(): return
	
	var push_vector = _dir_of_air * force
	
	for body in _bodies_in_air:
		if body is CharacterBody2D:
			# Dynamic Momentum Killer: Works for UP, DOWN, LEFT, and RIGHT!
			# If the fan is pushing on an axis, and the player is moving against it, kill the momentum.
			if _dir_of_air.y != 0 and sign(body.velocity.y) != sign(_dir_of_air.y):
				body.velocity.y = 0
			if _dir_of_air.x != 0 and sign(body.velocity.x) != sign(_dir_of_air.x):
				body.velocity.x = 0
				
			# Apply the wind force
			body.velocity += push_vector * delta
		elif body is RigidBody2D:
			# Physics objects need raw engine force applied
			body.apply_central_force(push_vector)
		else:
			# Fallback for Area2D, AnimatableBody2D, etc.
			body.global_position += (push_vector * non_physics_dampener) * delta
