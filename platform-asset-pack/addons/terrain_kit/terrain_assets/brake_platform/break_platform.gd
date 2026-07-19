@icon("res://addons/terrain_kit/terrain_assets/brake_platform/skull.svg")
@tool
extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $Icon
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_cs: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D

@export_category('Platform')
@export var texture: SpriteFrames = SpriteFrames.new():
	set(value):
		texture = value
		_update_visuals()

@export_range(1, 128, 1, "or_greater") var texture_width: int = 32:
	set(value):
		texture_width = max(1, value)
		_update_visuals()

@export_range(1, 128, 1, "or_greater") var texture_height: int = 32:
	set(value):
		texture_height = max(1, value)
		_update_visuals()

@export_group("One Way Collision", "col_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var col_enable: bool = false:
	set(value):
		col_enable = value
		_update_visuals()
@export_enum('NORTH','WEST','SOUTH','EAST') var col_way_pass_platform:int:
	set(value):
		col_way_pass_platform = value
		_update_visuals()
		
@export_subgroup("Circle", "circle_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var circle_enable: bool = false:
	set(value):
		circle_enable = value
		_update_visuals()
@export var circle_degrees:float = 0:
	set(value):
		circle_degrees = value
		_update_visuals()

@export_group('Platform Feel')
@export var rough: bool = false:
	set(value):
		rough = value
		_update_physics()

@export_range(0.0, 1.0) var friction: float = 1.0:
	set(value):
		friction = value
		_update_physics()

@export_range(0.0, 1.0) var bounce: float = 0.0:
	set(value):
		bounce = value
		_update_physics()

@export var absorbent: bool = false:
	set(value):
		absorbent = value
		_update_physics()

@export_range(0.1, 10.0, 0.1, "or_greater") var time_to_break: float = 1.0

var is_breaking: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_visuals()
		_update_physics()
	else:
		# RUNTIME ONLY: Connect the breaking logic
		area.body_entered.connect(start_braking)

func _update_visuals() -> void:
	if sprite == null or collision_shape == null or area_cs == null:
		return
		
	sprite.sprite_frames = texture
	collision_shape.one_way_collision = col_enable
	if circle_enable:
		var rad = deg_to_rad(-circle_degrees)
		collision_shape.one_way_collision_direction = Vector2(cos(rad), sin(rad))
	else:
		match col_way_pass_platform:
			0:
				collision_shape.one_way_collision_direction = Vector2(0.0,-1.0)
			1:
				collision_shape.one_way_collision_direction = Vector2(-1.0,0.0)
			2:
				collision_shape.one_way_collision_direction = Vector2(0.0,1.0)
			3:
				collision_shape.one_way_collision_direction = Vector2(1.0,0.0)
	
	if collision_shape.shape == null:
		collision_shape.shape = RectangleShape2D.new()
		
	if area_cs.shape == null:
		area_cs.shape = RectangleShape2D.new()
	
	var trigger_height:float = 3.0
	collision_shape.shape.size = Vector2(texture_width, texture_height)
	# Expands the trigger area slightly past the physical collision block
	area_cs.shape.size = Vector2(texture_width - 2.0, trigger_height)
	area_cs.position = Vector2(0, -(texture_height / 2.0) - (trigger_height / 2.0))

func _update_physics() -> void:
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
		physics_material_override.resource_local_to_scene = true 
		
	physics_material_override.rough = rough
	physics_material_override.friction = friction
	physics_material_override.bounce = bounce
	physics_material_override.absorbent = absorbent

func start_braking(_body: Node2D) -> void:
	# Prevent multiple bodies from triggering the sequence multiple times
	if is_breaking:
		return
		
	is_breaking = true
	
	# Cleaner way to wait without manually creating/adding Timer nodes
	await get_tree().create_timer(time_to_break).timeout
	
	sprite.play("default")
	await sprite.animation_finished
	queue_free()
