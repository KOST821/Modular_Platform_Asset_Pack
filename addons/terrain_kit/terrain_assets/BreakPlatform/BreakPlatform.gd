@tool
@icon("bone_fracture.svg")
## A fragile platform that crumbles shortly after a physics body stands on it.
extends Platform
class_name BreakPlatform

## The time (in seconds) the player can stand on the platform before it vanishes.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec") var break_time:float = 1.0
## The area that sees if someone is standing on top of the platform.
@export var area:Area2D
## The [CollisionShape2D] used by the [Area2D] to detect the player. Automatically resized to match the platform.
@export var area_collision_shape:CollisionShape2D

var _is_breaking: bool = false
var _main_shape_unique_break:bool = false

var _tween:Tween

func _from_start() -> void:
	if ! size_changed.is_connected(_update_attack_area):
		size_changed.connect(_update_attack_area)
	area.body_entered.connect(start_breaking)

func start_breaking(_body: Node2D) -> void:
	print("ok")
	# Prevent multiple bodies from triggering the sequence multiple times
	if _is_breaking:
		return
		
	_is_breaking = true
	
	# Cleaner way to wait without manually creating/adding Timer nodes
	await get_tree().create_timer(break_time).timeout
	if not is_instance_valid(self) or not is_instance_valid(sprite): 
		return
	
	if sprite is AnimatedSprite2D:
		sprite.play("default")
		await sprite.animation_finished
	else:
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_tween.tween_property(sprite,"modulate:a", 0.0, 0.4)
		await _tween.finished
		queue_free()

func _update_attack_area(width:int,height:int) -> void:
	if sprite == null or collision_shape == null or area_collision_shape == null:
		return
	
	if area_collision_shape.shape == null:
		return
	
	# Only duplicate ONCE to prevent memory leaks and editor detachment
	if Engine.is_editor_hint() and not _main_shape_unique_break:
		area_collision_shape.shape = area_collision_shape.shape.duplicate()
		_main_shape_unique_break = true
	
	area_collision_shape.shape.resource_local_to_scene = true
	
	var trigger_height:float = 3.0
	if area_collision_shape.shape is RectangleShape2D:
	# Expands the trigger area slightly past the physical collision block
		area_collision_shape.shape.size = Vector2(width - 2.0, trigger_height)
		area_collision_shape.position = Vector2(0, -(height / 2.0) - (trigger_height / 2.0))
