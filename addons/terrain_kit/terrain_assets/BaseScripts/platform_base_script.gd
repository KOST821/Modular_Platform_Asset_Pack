@tool
@icon("gate.svg")
@abstract class_name Platform
## The abstract base class for all platforms. Handles visual tiling, collision resizing, one-way collisions, and hazards.
extends StaticBody2D

signal size_changed(width:int, height:int)

@export_category("Assets")
## The [Node2D] that will be used for showing visuals.
@export var sprite: Node2D:
	set(value):
		sprite = value
		if value is Sprite2D:
			_is_animated = false
		elif value is AnimatedSprite2D:
			_is_animated = true
		update_configuration_warnings()
		_update_visuals()

@export_category("Collision Shape")
## The [CollisionShape2D] that will provide the collision for the platform.
@export var collision_shape: CollisionShape2D:
	set(value):
		collision_shape = value
		update_configuration_warnings()
		_update_visuals()

## Custom debug color for the collision shape.
@export var debug_color: Color = Color("0099b36b"):
	set(color):
		debug_color = color # ALWAYS set the value first!
		if collision_shape:
			collision_shape.debug_color = color

@export_category('Platform')
## The [Texture2D] of the Terrain. Used if [member Platform.sprite] is a [Sprite2D].
@export var texture: Texture2D:
	set(value):
		texture = value
		_update_visuals()

## The [SpriteFrames] of the Terrain. Used if [member Platform.sprite] is a [AnimatedSprite2D].
@export var spriteframes: SpriteFrames:
	set(value):
		spriteframes = value
		_update_visuals()

## The textures width, if greater than the original it adds a second texture.
@export_range(0, 128, 1, "or_greater", "suffix:px") var texture_width: int = 32:
	set(value):
		texture_width = value
		_update_visuals()
		if is_node_ready():
			_update_attack()

## The textures height, if greater than the original it adds a second texture.
@export_range(0, 128, 1, "or_greater", "suffix:px") var texture_height: int = 32:
	set(value):
		texture_height = value
		_update_visuals()
		if is_node_ready():
			_update_attack()

@export_group("One Way Collision", "col_")
## If [b]enabled[/b], characters can jump through the platform from the specified direction.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var col_enable: bool = false:
	set(value):
		col_enable = value
		if is_node_ready():
			_update_visuals()
## The cardinal direction from which the player can pass through the platform.
@export_enum('NORTH','WEST','SOUTH','EAST') var col_way_pass_platform:int:
	set(value):
		col_way_pass_platform = value
		if is_node_ready():
			_update_visuals()
		
@export_subgroup("Circle", "circle_")
## If [b]enabled[/b], overrides the cardinal direction and allows arbitrary angle rotation for one-way collision.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var circle_enable: bool = false:
	set(value):
		circle_enable = value
		if is_node_ready():
			_update_visuals()
## The exact angle in degrees for the one-way collision pass-through.
@export_custom(PROPERTY_HINT_NONE, "suffix:°") var circle_degrees:float = 0:
	set(value):
		circle_degrees = value
		if is_node_ready():
			_update_visuals()

@export_category('Attack Part')
@export_group('Is Attacking')
## If enabled, your platform has a Hazard (e.g., spikes).
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var is_attacking: bool = false:
	set(value):
		is_attacking = value
		_update_type_visibility()
		if is_node_ready():
			_update_attack()
			
## The helth your Hazard will reduce.
@export_range(0.0, 100.0, 0.1, "or_greater", "hide_control", "suffix:hp") var damage: float = 5
## The time that the Hazard will wait untill it activates.
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_control", "suffix:sec") var activate_time: float = 0.2
## The time that the Hazard will be active.
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_control", "suffix:sec") var active_time: float = 0.2

## If [b]false[/b], the script will stop auto-sizing the hitbox so you can build it manually.
@export var auto_size_attack: bool = true:
	set(value):
		auto_size_attack = value
		if is_node_ready():
			_update_attack()
			
## The CollisionShape of the HitBox.
@export var attack: CollisionShape2D:
	set(value):
		attack = value
		if is_node_ready():
			_update_attack()

@export_subgroup('Direction', 'dir_')
## The location your Hazard will be facing.
@export_enum('NORTH', 'WEST', 'SOUTH', 'EAST') var dir_location_of_attack: int = 0:
	set(value):
		dir_location_of_attack = value
		if is_node_ready():
			_update_attack()

## How far the attack will be from the main Hazard.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var dir_attack_reach: float = 3.0:
	set(value):
		dir_attack_reach = max(1.0, value)
		if is_node_ready():
			_update_attack()

@export_subgroup("Direction/Circle", "circle_dir_")
## If enabled, the "location of attack" is overwriten. Now the location your Hazard will be facing is defined by a circle.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var circle_dir_enable: bool = false:
	set(value):
		circle_dir_enable = value
		if is_node_ready():
			_update_attack()
## The degrees of the circle for the position. A classic XY axis system.
@export_range(0.0, 360.0, 0.1, "suffix:°") var circle_dir_degrees: float = 0.0:
	set(value):
		circle_dir_degrees = value
		if is_node_ready():
			_update_attack()

var _is_animated: bool = false
var _main_shape_unique: bool = false
var _attack_shape_unique: bool = false

var _is_active:bool = false
var _activate_timer:float
var _active_timer:float

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if sprite and not (sprite is Sprite2D or sprite is AnimatedSprite2D):
		warnings.append("Sprite MUST be a Sprite2D or an AnimatedSprite2D.")
	
	if texture != null and sprite is AnimatedSprite2D:
		warnings.append("Texture assigned, but sprite is AnimatedSprite2D. Use SpriteFrames.")
		
	if collision_shape != null and collision_shape.shape == null:
		warnings.append("CollisionShape2D is missing a Shape2D resource.")
		
	return warnings

func _ready() -> void:
	_update_visuals()
	_update_attack()
	_from_start()
	if not Engine.is_editor_hint():
		_activate_timer = activate_time
		_active_timer = active_time
		# FORCE the hazard off on frame 1 so the timer handles the initial activation
		if is_attacking and attack != null:
			attack.set_deferred("disabled", true)

## A clean replacement for _ready() intended for child scripts.
func _from_start() -> void: 
	pass

func _update_visuals() -> void:
	if not is_node_ready():
		return
	
	# 1. Update Sprite Logic
	if sprite != null:
		if not _is_animated and sprite is Sprite2D:
			sprite.texture = texture
			if texture != null:
				sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
				sprite.region_enabled = true
				sprite.region_rect = Rect2(0, 0, texture_width, texture_height)
		elif _is_animated and sprite is AnimatedSprite2D:
			sprite.sprite_frames = spriteframes
			if not Engine.is_editor_hint(): 
				sprite.play()
	
	# 2. Update Main Collision Logic safely
	if collision_shape != null and collision_shape.shape != null:
		var shape: Shape2D = collision_shape.shape
		
		# Only duplicate ONCE to prevent memory leaks and editor detachment
		if Engine.is_editor_hint() and not _main_shape_unique:
			shape = shape.duplicate()
			collision_shape.shape = shape
			_main_shape_unique = true
		
		shape.resource_local_to_scene = true
		collision_shape.debug_color = debug_color 
		
		# Handle One-Way Collision & Rotation
		collision_shape.one_way_collision = col_enable
		
		var active_w: float = texture_width
		var active_h: float = texture_height
		
		if circle_enable:
			# NOTE: Freely rotating a rectangle collision will desync it from the unrotated sprite!
			collision_shape.rotation = deg_to_rad(circle_degrees)
		else:
			match col_way_pass_platform:
				0: # NORTH (Default)
					collision_shape.rotation = 0.0
				1: # WEST
					collision_shape.rotation = PI / 2.0
					active_w = texture_height
					active_h = texture_width
				2: # SOUTH
					collision_shape.rotation = PI
				3: # EAST
					collision_shape.rotation = -PI / 2.0
					active_w = texture_height
					active_h = texture_width
		
		# Apply sizes based on the potentially swapped dimensions
		if shape is RectangleShape2D:
			shape.size = Vector2(active_w, active_h)
		elif shape is CircleShape2D:
			shape.radius = texture_width / 2.0
		elif shape is CapsuleShape2D:
			shape.radius = active_w / 2.0
			shape.height = active_h
		else:
			push_warning("The ", collision_shape.name, "'s shape (", shape.get_class(), ") is not supported by Platform auto-sizing.")
	size_changed.emit(texture_width,texture_height)

func _update_attack() -> void:
	if not (is_attacking and auto_size_attack):
		return
	if attack == null or attack.shape == null:
		return 
	
	var shape: Shape2D = attack.shape
	
	# Only duplicate ONCE
	if Engine.is_editor_hint() and not _attack_shape_unique:
		shape = shape.duplicate()
		attack.shape = shape
		_attack_shape_unique = true
		
	shape.resource_local_to_scene = true
	
	var trigger_depth: float = dir_attack_reach
	var half_w = texture_width / 2.0
	var half_h = texture_height / 2.0
	
	if circle_dir_enable:
		if shape is RectangleShape2D:
			shape.size = Vector2(texture_width - 2.0, trigger_depth)
		var rad = deg_to_rad(-circle_dir_degrees)
		var dir_vector = Vector2(cos(rad), sin(rad))
		attack.position = dir_vector * max(half_w, half_h)
		attack.rotation = rad + (PI/2) 
	else:
		attack.rotation = 0 
		match dir_location_of_attack:
			0: 
				if shape is RectangleShape2D: shape.size = Vector2(texture_width - 2.0, trigger_depth)
				attack.position = Vector2(0, -half_h - (trigger_depth / 2.0))
			1: 
				if shape is RectangleShape2D: shape.size = Vector2(trigger_depth, texture_height - 2.0)
				attack.position = Vector2(-half_w - (trigger_depth / 2.0), 0)
			2: 
				if shape is RectangleShape2D: shape.size = Vector2(texture_width - 2.0, trigger_depth)
				attack.position = Vector2(0, half_h + (trigger_depth / 2.0))
			3: 
				if shape is RectangleShape2D: shape.size = Vector2(trigger_depth, texture_height - 2.0)
				attack.position = Vector2(half_w + (trigger_depth / 2.0), 0)

func _update_type_visibility() -> void:
	if Engine.is_editor_hint() and attack != null:
		attack.set_deferred("disabled", not is_attacking)

func _process(delta: float) -> void:
	# Stop this from running in the editor and eating CPU
	if Engine.is_editor_hint(): return
	
	# Only run the timer if the prop is actually an attacking hazard
	if not is_attacking or attack == null: return
	
	if _is_active == false:
		if _activate_timer > 0.0:
			_activate_timer -= delta
			if _activate_timer <= 0.0:
				_is_active = true
				_activate_timer = activate_time
				attack.set_deferred("disabled", false) # Turn hazard ON
	
	else:
		if _active_timer > 0.0:
			_active_timer -= delta
			if _active_timer <= 0.0:
				_is_active = false
				_active_timer = active_time
				attack.set_deferred("disabled", true) # Turn hazard OFF
