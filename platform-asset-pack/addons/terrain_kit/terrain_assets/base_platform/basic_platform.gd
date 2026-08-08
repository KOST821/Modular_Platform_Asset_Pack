@icon("res://addons/terrain_kit/terrain_assets/base_platform/tilemap.svg")
@tool
extends StaticBody2D

const platform_uid11299087490986: Variant = null

@onready var sprite: Sprite2D = $Icon
@onready var collision_shape: CollisionShape2D = $PlatformsCollision

@export_category('Platform')
## The texture of the Terrain.
@export var texture:Texture2D:
	set(value):
		texture = value
		if is_node_ready():
			_update_visuals()
## The textures width, if grater than the original it adds a second texture.
@export_range(0, 128, 1, "or_greater") var texture_width:int = 32:
	set(value):
		texture_width = value
		if is_node_ready():
			_update_visuals()
## The textures height, if grater than the original it adds a second texture.
@export_range(0, 128, 1, "or_greater") var texture_height:int = 32:
	set(value):
		texture_height = value
		if is_node_ready():
			_update_visuals()

@export_group('Platform Feel')
## If true, the physics engine will use the friction of the object marked as "rough" when two objects collide. If false, the physics engine will use the lowest friction of all colliding objects instead. If true for both colliding objects, the physics engine will use the highest friction.
@export var rough:bool = false:
	set(value):
		rough = value
		physics_material_override.rough = rough
## The body's friction. Values range from 0 (frictionless) to 1 (maximum friction).
@export_range(0.0,1.0) var friction:float = 1.0:
	set(value):
		friction = value
		physics_material_override.friction = friction
## The body's bounciness. Values range from 0 (no bounce) to 1 (full bounciness). Note: Even with bounce set to 1.0, some energy will be lost over time due to linear and angular damping. To have a physics body that preserves all its energy over time, set bounce to 1.0, the body's linear damp mode to Replace (if applicable), its linear damp to 0.0, its angular damp mode to Replace (if applicable), and its angular damp to 0.0.
@export_range(0.0,1.0) var bounce:float = 0.0:
	set(value):
		bounce = value
		physics_material_override.bounce = bounce
## If true, subtracts the bounciness from the colliding object's bounciness instead of adding it.
@export var absorbent:bool = false:
	set(value):
		absorbent = value
		physics_material_override.absorbent = absorbent

func _ready() -> void:
	_update_visuals()
	_update_physics()

func _update_visuals() -> void:
	if sprite == null or collision_shape == null:
		return
		
	sprite.texture = texture
	
	# THE TILING MAGIC:
	# We force the sprite to repeat and use the width/height to draw it back-to-back.
	if texture != null:
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, texture_width, texture_height)
	
	if collision_shape.shape == null:
		collision_shape.shape = RectangleShape2D.new()
	
	collision_shape.shape.resource_local_to_scene = true
	
	collision_shape.shape.size = Vector2(texture_width, texture_height)

func _update_physics() -> void:
	# THE PHYSICS SAFETY NET:
	# If there is no material, create one safely.
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
		# CRITICAL: This ensures if your friend makes one bouncy platform, it doesn't make ALL platforms bouncy.
		physics_material_override.resource_local_to_scene = true 
		
	physics_material_override.rough = rough
	physics_material_override.friction = friction
	physics_material_override.bounce = bounce
	physics_material_override.absorbent = absorbent
