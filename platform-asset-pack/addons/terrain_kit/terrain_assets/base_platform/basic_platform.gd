@icon("res://addons/terrain_kit/terrain_assets/base_platform/tilemap.svg")
@tool
extends StaticBody2D

@onready var sprite: Sprite2D = $Icon
@onready var collision_shape: CollisionShape2D = $PlatformsCollision

@export_category('Platform')
@export var texture:Texture2D:
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

@export_group('Platform Feel')
@export var rough:bool = false:
	set(value):
		rough = value
		physics_material_override.rough = rough
@export_range(0.0,1.0) var friction:float = 1.0:
	set(value):
		friction = value
		physics_material_override.friction = friction
@export_range(0.0,1.0) var bounce:float = 0.0:
	set(value):
		bounce = value
		physics_material_override.bounce = bounce
@export var absorbent:bool = false:
	set(value):
		absorbent = value
		physics_material_override.absorbent = absorbent

func _ready() -> void:
	# Catch up both visual and physics states when the node finishes loading
	if Engine.is_editor_hint():
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
