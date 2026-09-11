@tool
@icon("moving_platform.svg")
## A platform that follows a specific [Path2D] with optional smooth acceleration.
extends Platform
class_name MovingPlatform

@export_category("Platform Movement")
## The speed at which the platform will move if acceleration is disabled.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var speed: float = 150.0
## The [Path2D] the platform will follow. Must be assigned for movement to work.
@export var path: Path2D

@export_subgroup("Acceleration", "acc_")
## If enabled, overrides "speed" and forces the platform to accelerate smoothly between ends.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var acc_acceleration_enable: bool = false
## The exact time (in seconds) it takes to reach the end of the path.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec") var acc_travel_time: float = 3.0 
## The time (in seconds) the platform rests before moving again.
@export_custom(PROPERTY_HINT_NONE, "suffix:sec") var acc_wait_time: float = 1.0 # Rest time at ends

var _path_follow:PathFollow2D = null
var _moving_forward: bool = true

var has_error: bool = false

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		if not (self as Node) is AnimatableBody2D:
			has_error = true
		else:
			has_error = false
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if has_error:
		warnings.append("MovePlatform MUST BE AnimatableBody2D.")
		
	if sprite and not (sprite is Sprite2D or sprite is AnimatedSprite2D):
		warnings.append("Sprite MUST be a Sprite2D or an AnimatedSprite2D.")
	
	if texture != null and sprite is AnimatedSprite2D:
		warnings.append("Texture assigned, but sprite is AnimatedSprite2D. Use SpriteFrames.")
		
	if collision_shape != null and collision_shape.shape == null:
		warnings.append("CollisionShape2D is missing a Shape2D resource.")
		
	return warnings

func _from_start() -> void:
	set_process(false)
	if not Engine.is_editor_hint():
		if not path:
			push_error("No path added to, ",self," !")
			return
		_path_follow = PathFollow2D.new()
		_path_follow.name = "PathShower"
		path.add_child(_path_follow)
		var remote:RemoteTransform2D = RemoteTransform2D.new()
		remote.name = "PositionTransferer"
		remote.update_position = true
		remote.update_rotation = false
		remote.update_scale = false
		_path_follow.progress = 0.0
		_path_follow.loop = false
		_path_follow.add_child(remote)
		remote.remote_path = remote.get_path_to(self)
		print(remote.remote_path)
		if acc_acceleration_enable:
			set_physics_process(false)
			start_patrol()
		else:
			set_physics_process(true)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	# Linear ping-pong movement using pixels (progress), not ratio
	if _moving_forward:
		_path_follow.progress += speed * delta
		if _path_follow.progress_ratio >= 1.0:
			_moving_forward = false
	else:
		_path_follow.progress -= speed * delta
		if _path_follow.progress_ratio <= 0.0:
			_moving_forward = true

func start_patrol() -> void:
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops()
	
	tween.tween_property(_path_follow, "progress_ratio", 1.0, acc_travel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(acc_wait_time)
	
	tween.tween_property(_path_follow, "progress_ratio", 0.0, acc_travel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(acc_wait_time)
