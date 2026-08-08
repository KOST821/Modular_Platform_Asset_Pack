@icon("res://addons/terrain_kit/terrain_assets/props_or_hazards/tree.svg")
@tool
extends StaticBody2D

const platform_uid11299087490986: Variant = null

@onready var StillIcon: Sprite2D = $Icon
@onready var MovingIcon: AnimatedSprite2D = $AnimatedIcon
@onready var collision: CollisionShape2D = $PropsCollision
@onready var attack: CollisionShape2D = $Area2D/attack

@export_category('Hazard Settings')
@export_group('Is Attacking')
## If enabled, your prop is a Hazard (e.g., spikes).
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var is_attacking: bool = false:
	set(value):
		is_attacking = value
		if is_node_ready():
			_update_type_visibility()
## The damage your Hazard will make.
@export_range(1.0, 100.0, 1.0, "or_greater") var damage: int = 5
## The time that the Hazard will wait untill it activates.
@export_range(0.0, 10.0, 0.1, "or_greater") var activate_time: float = 0.2
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

@export_category("Prop Setup")
## The type of Prop it is. If STILL the prop has no animation else it has.
@export_enum('Animated', 'Still') var type: int = 1:
	set(value):
		type = value
		_update_type_visibility()

@export_subgroup('Animated visuals', 'anim_')
## The spriteframes of the animated Prop.
@export var anim_texture: SpriteFrames:
	set(value):
		anim_texture = value
		if is_node_ready():
			_update_visuals()

@export_subgroup('Still visuals', 'st_')
## The textures of the still Prop.
@export var st_texture: Texture2D:
	set(value):
		st_texture = value
		if is_node_ready():
			_update_visuals()

@export_category("Dimensions")
## The width of the texture.
@export_range(1, 128, 1, "or_greater") var texture_width: int = 32:
	set(value):
		texture_width = max(1, value)
		if is_node_ready():
			_update_visuals()
## The height of the texture.
@export_range(1, 128, 1, "or_greater") var texture_height: int = 32:
	set(value):
		texture_height = max(1, value)
		if is_node_ready():
			_update_visuals()

var is_active: bool = false
var activate_timer: float
var active_timer: float

func _ready() -> void:
	_update_type_visibility()
	_update_visuals()
	_update_physics()
	
	if not Engine.is_editor_hint():
		activate_timer = activate_time
		active_timer = active_time
		
		if is_attacking and attack:
			if activate_time <= 0.0:
				# ALWAYS ACTIVE: Turn it on and kill the process loop to save CPU!
				attack.set_deferred("disabled", false)
				set_process(false) 
			else:
				# TIMED HAZARD: Start disabled and let _process handle the toggling
				attack.set_deferred("disabled", true)

func _update_type_visibility() -> void:
	if StillIcon == null or MovingIcon == null or attack == null:
		return
		
	if type == 0: 
		StillIcon.visible = false
		MovingIcon.visible = true
	else: 
		StillIcon.visible = true
		MovingIcon.visible = false
	
	# Only manage baseline editor visibility here. Runtime toggling belongs in _process.
	if Engine.is_editor_hint():
		if is_attacking == false:
			attack.set_deferred("disabled", true)
		else:
			attack.set_deferred("disabled", false)

func _update_visuals() -> void:
	if StillIcon == null or collision == null or MovingIcon == null or attack == null:
		return
		
	StillIcon.texture = st_texture
	MovingIcon.sprite_frames = anim_texture
	
	var current_shape = collision.shape
	if current_shape == null:
		return # Let the user add a shape without spamming the console
		
	if current_shape is RectangleShape2D:
		current_shape.resource_local_to_scene = true
		current_shape.size = Vector2(texture_width, texture_height)
	elif current_shape is CapsuleShape2D:
		current_shape.resource_local_to_scene = true
		current_shape.radius = texture_width / 2.0
		current_shape.height = texture_height
	elif current_shape is CircleShape2D:
		current_shape.resource_local_to_scene = true
		current_shape.radius = max(texture_width, texture_height) / 2.0
	else:
		printerr("Prop: Shape is not supported for auto-resizing.")
	
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

func _update_physics() -> void:
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
		physics_material_override.resource_local_to_scene = true 
		
	physics_material_override.rough = false
	physics_material_override.friction = 1.0
	physics_material_override.bounce = 0.0
	physics_material_override.absorbent = false

func _process(delta: float) -> void:
	# Stop this from running in the editor and eating CPU
	if Engine.is_editor_hint(): return
	
	# Only run the timer if the prop is actually an attacking hazard
	if not is_attacking or attack == null: return
	
	if is_active == false:
		if activate_timer > 0.0:
			activate_timer -= delta
			if activate_timer <= 0.0:
				is_active = true
				activate_timer = activate_time
				attack.set_deferred("disabled", false) # Turn hazard ON
	
	else:
		if active_timer > 0.0:
			active_timer -= delta
			if active_timer <= 0.0:
				is_active = false
				active_timer = active_time
				attack.set_deferred("disabled", true) # Turn hazard OFF
