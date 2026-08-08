@icon("res://addons/terrain_kit/terrain_assets/one_way_collision_platform/motion_vector.svg")
@tool
extends StaticBody2D

const platform_uid11299087490986: Variant = null

@onready var collision_shape:CollisionShape2D = $PlatformsCollision
@onready var sprite: Sprite2D = $Icon

@export_category('One Way Platform')
## The texture of the Terrain
@export var texture:Texture2D:
	set(value):
		texture = value
		if is_node_ready():
			_update_visuals()
## The width of the texture.
@export_range(1, 128, 1, "or_greater") var texture_width:int = 32:
	set(value):
		texture_width = value
		if is_node_ready():
			_update_visuals()
## The height of the texture.
@export_range(1, 128, 1, "or_greater") var texture_height:int = 32:
	set(value):
		texture_height = value
		if is_node_ready():
			_update_visuals()
## The location your Platform will be facing.
@export_enum('NORTH','WEST','SOUTH','EAST') var way_pass_platform:int:
	set(value):
		way_pass_platform = value
		if is_node_ready():
			_update_visuals()

@export_subgroup("Circle", "circle_")
## If enabled, the "way pass platform" is overwriten. Now the location your Platform will be facing is defined by a circle.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var circle_enable: bool = false:
	set(value):
		circle_enable = value
		if is_node_ready():
			_update_visuals()

## The degrees of the circle for the position. A classic XY axis system.
@export var circle_degrees:float = 0:
	set(value):
		circle_degrees = value
		if is_node_ready() and collision_shape:
			var rad = deg_to_rad(-circle_degrees)
			collision_shape.one_way_collision_direction = Vector2(cos(rad), sin(rad))

func _update_visuals() -> void:
	# 1. The Block: If nodes don't exist yet, do absolutely nothing.
	if sprite == null or collision_shape == null:
		return
		
	# 2. The Application: If we get past the block, apply everything safely.
	sprite.texture = texture
	
	if collision_shape.shape == null:
		collision_shape.shape = RectangleShape2D.new()
	
	collision_shape.shape.resource_local_to_scene = true
	collision_shape.shape.size = Vector2(texture_width, texture_height)
	if not circle_enable:
			match way_pass_platform:
				0:
					collision_shape.one_way_collision_direction = Vector2(0.0,-1.0)
				1:
					collision_shape.one_way_collision_direction = Vector2(-1.0,0.0)
				2:
					collision_shape.one_way_collision_direction = Vector2(0.0,1.0)
				3:
					collision_shape.one_way_collision_direction = Vector2(1.0,0.0)
	else :
		var rad = deg_to_rad(-circle_degrees)
		collision_shape.one_way_collision_direction = Vector2(cos(rad), sin(rad))
