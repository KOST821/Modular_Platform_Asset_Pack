@icon("res://addons/terrain_kit/terrain_assets/moving_platform/moving_platform.svg")
@tool
extends Path2D

@onready var path_follow_2d: PathFollow2D = $PathShower
@onready var sprite: AnimatedSprite2D = $Standing_Pltf/Icon
@onready var collision_shape_2d: CollisionShape2D = $Standing_Pltf/PlatformsCollision

@export_category('Platform visuals')
@export var texture:SpriteFrames = SpriteFrames.new():
	set(value):
		texture = value
		_update_visuals()

@export_range(0, 128, 0, "or_greater") var texture_width:int = 32:
	set(value):
		texture_width = value
		_update_visuals()

@export_range(0, 128, 0, "or_greater") var texture_height:int = 32:
	set(value):
		texture_height = value
		_update_visuals()

@export_category("Platform Movement")
@export var speed: float = 150.0

@export_subgroup("Acceleration", "acc_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var acc_acceleration_enable: bool = false
@export var acc_travel_time: float = 3.0 # Seconds to reach the end
@export var acc_wait_time: float = 1.0 # Rest time at ends

var moving_forward: bool = true

func _ready() -> void:
	# Ensure the platform always starts at the beginning
	path_follow_2d.progress_ratio = 0.0
	path_follow_2d.loop = false
	
	if not Engine.is_editor_hint():
		if acc_acceleration_enable:
			set_physics_process(false)
			start_patrol()
		else:
			set_physics_process(true)
	_update_visuals()

func _update_visuals() -> void:
	# 1. The Block: If nodes don't exist yet, do absolutely nothing.
	if sprite == null or collision_shape_2d == null:
		return
		
	# 2. The Application: If we get past the block, apply everything safely.
	sprite.sprite_frames = texture
	sprite.play()
	
	if collision_shape_2d.shape == null:
		collision_shape_2d.shape = RectangleShape2D.new()
	
	collision_shape_2d.shape.size = Vector2(texture_width, texture_height)

func start_patrol() -> void:
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops()
	
	tween.tween_property(path_follow_2d, "progress_ratio", 1.0, acc_travel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(acc_wait_time)
	
	tween.tween_property(path_follow_2d, "progress_ratio", 0.0, acc_travel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(acc_wait_time)

func _physics_process(delta: float) -> void:
	# Linear ping-pong movement using pixels (progress), not ratio
	if moving_forward:
		path_follow_2d.progress += speed * delta
		if path_follow_2d.progress_ratio >= 1.0:
			moving_forward = false
	else:
		path_follow_2d.progress -= speed * delta
		if path_follow_2d.progress_ratio <= 0.0:
			moving_forward = true
