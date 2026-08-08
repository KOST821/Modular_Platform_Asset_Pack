@icon("res://addons/terrain_kit/terrain_assets/moving_platform/moving_platform.svg")
@tool
extends Path2D

const platform_uid11299087490986: Variant = null

@onready var path_follow_2d: PathFollow2D = $PathShower
@onready var sprite: AnimatedSprite2D = $Standing_Pltf/Icon
@onready var collision_shape_2d: CollisionShape2D = $Standing_Pltf/PlatformsCollision
@onready var attack: CollisionShape2D = $Standing_Pltf/Area2D/CollisionShape2D

@export_category('Platform visuals')
## The spriteframes of the animated platform. If the platform isn't animated the just add a still spriteframe.
@export var texture:SpriteFrames = SpriteFrames.new():
	set(value):
		texture = value
		if is_node_ready():
			_update_visuals()
## The width of the texture.
@export_range(0, 128, 1, "or_greater") var texture_width:int = 32:
	set(value):
		texture_width = value
		if is_node_ready():
			_update_visuals()
## The height of the texture.
@export_range(0, 128, 1, "or_greater") var texture_height:int = 32:
	set(value):
		texture_height = value
		if is_node_ready():
			_update_visuals()

@export_category("Platform Movement")
## The speed which the platform will move.
@export var speed: float = 150.0

@export_subgroup("Acceleration", "acc_")
## If enabled, it overwrites the "speed" and make the platform accelerate.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var acc_acceleration_enable: bool = false
## The time (in seconds) to reach the end
@export var acc_travel_time: float = 3.0 
## The rest time (in seconds) at ends
@export var acc_wait_time: float = 1.0 # Rest time at ends

@export_category('Attack Part')
@export_group('Is Attacking')
## If enabled, your platform has a Hazard (e.g., spikes).
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var is_attacking: bool = false:
	set(value):
		is_attacking = value
		_update_type_visibility()
## The damage your Hazard will make.
@export_range(0, 100, 1, "or_greater") var damage: int = 5
## The time that the Hazard will wait untill it activates.
@export_range(0.1, 10.0, 0.1, "or_greater") var activate_time: float = 0.2
## The time that the Hazard will be active.
@export_range(0.1, 10.0, 0.1, "or_greater") var active_time: float = 0.2

@export_subgroup('Direction', 'dir_')
## The location your Hazard will be facing.
@export_enum('NORTH', 'WEST', 'SOUTH', 'EAST') var dir_location_of_attack: int = 0:
	set(value):
		dir_location_of_attack = value
		if is_node_ready():
			_update_visuals()

## How far the attack will be from the main Hazard.
@export var dir_attack_reach: float = 3.0:
	set(value):
		dir_attack_reach = max(1.0, value)
		if is_node_ready():
			_update_visuals()

@export_subgroup("Direction/Circle", "circle_dir_")
## If enabled, the "location of attack" is overwriten. Now the location your Hazard will be facing is defined by a circle.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var circle_dir_enable: bool = false:
	set(value):
		circle_dir_enable = value
		if is_node_ready():
			_update_visuals()
## The degrees of the circle for the position. A classic XY axis system.
@export_range(0.0, 360.0) var circle_dir_degrees: float = 0.0:
	set(value):
		circle_dir_degrees = value
		if is_node_ready():
			_update_visuals()

@export_group("Collision")
## The layers this platform exists on.
@export_flags_2d_physics var collision_layer: int = 1:
	set(value):
		collision_layer = value
		if is_node_ready() and get_node_or_null("Standing_Pltf") and sprite.is_node_ready():
			var pltf:AnimatableBody2D = sprite.get_parent()
			pltf.collision_layer = collision_layer

## The layers this platform scans for collisions.
@export_flags_2d_physics var collision_mask: int = 1:
	set(value):
		collision_mask = value
		if is_node_ready() and get_node_or_null("Standing_Pltf"):
			var pltf:AnimatableBody2D = sprite.get_parent()
			pltf.collision_mask = collision_mask

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
	
	collision_shape_2d.shape.resource_local_to_scene = true
	
	collision_shape_2d.shape.size = Vector2(texture_width, texture_height)
	
	if attack.shape == null:
		attack.shape = RectangleShape2D.new()
	
	attack.shape.resource_local_to_scene = true
	
	var trigger_depth: float = dir_attack_reach
	var half_w = texture_width / 2.0
	var half_h = texture_height / 2.0
	
	if circle_dir_enable:
		attack.shape.size = Vector2(texture_width - 2.0, trigger_depth)
		var rad = deg_to_rad(-circle_dir_degrees)
		var dir_vector = Vector2(cos(rad), sin(rad))
		attack.position = dir_vector * max(half_w, half_h)
		attack.rotation = rad + (PI/2) 
	else:
		attack.rotation = 0 
		match dir_location_of_attack:
			0: 
				attack.shape.size = Vector2(texture_width - 2.0, trigger_depth)
				attack.position = Vector2(0, -half_h - (trigger_depth / 2.0))
			1: 
				attack.shape.size = Vector2(trigger_depth, texture_height - 2.0)
				attack.position = Vector2(-half_w - (trigger_depth / 2.0), 0)
			2: 
				attack.shape.size = Vector2(texture_width - 2.0, trigger_depth)
				attack.position = Vector2(0, half_h + (trigger_depth / 2.0))
			3: 
				attack.shape.size = Vector2(trigger_depth, texture_height - 2.0)
				attack.position = Vector2(half_w + (trigger_depth / 2.0), 0)

func _update_type_visibility()->void:
	# Only manage baseline editor visibility here. Runtime toggling belongs in _process.
	if Engine.is_editor_hint():
		if is_attacking == false:
			attack.set_deferred("disabled", true)
		else:
			attack.set_deferred("disabled", false)

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
