@tool
@icon("lever.svg")
extends Area2D
class_name Lever

enum WAY {LEFT_TO_RIGHT, RIGHT_TO_LEFT}

## Emitted when pressed.
signal pressed(lever:Node2D)
## Emitted when released.
signal released(lever:Node2D)
## Emitted when toggled.
signal toggle(is_on:bool, lever:Node2D)

@export_category("Setup")
@export_enum("LEFT","RIGHT") var starting_position:String = "RIGHT"
@export var sprite: Node2D:
	set(value):
		sprite = value
		update_configuration_warnings()

@export var collision: Node2D:
	set(value):
		collision = value
		update_configuration_warnings()

var _is_left:bool = false

@export_category("Settings")
@export_range(0, 100, 1,"or_greater", "hide_control", "suffix:px") var texture_width:int = 32
## If the sprite is an [AnimatedSprite2D] sets the animation true run.
@export var animation_play:WAY = WAY.RIGHT_TO_LEFT

var _switched:bool = false

const TIME:float = 0.27

func _get_configuration_warnings() -> PackedStringArray:
	if sprite == null:
		return ['You did not filled the "sprite"']
	
	elif not (sprite is AnimatedSprite2D or sprite is Sprite2D):
		return ['Your sprite MUST be an AnimatedSprite2D or Sprite2D']
	
	if collision == null:
		return ['You did not filled the "collision"']
	
	elif not (collision is CollisionPolygon2D or collision is CollisionShape2D):
		return ['Your collision MUST be an CollisionPolygon2D or CollisionShape2D']
	
	return []

func _ready() -> void:
	set_process(false)
	match starting_position:
		"LEFT":
			_is_left = true
		"RIGHT":
			_is_left = false
	
	body_entered.connect(_switch)
	set_correct_collision()

func set_correct_collision() -> void:
	collision.position.x = 0.0
	
	match _is_left:
		true:
			collision.position.x -= texture_width
		false:
			collision.position.x += texture_width

func _switch(_body:Node2D) -> void:
	print("enter")
	if _switched:
		return
	
	if sprite is AnimatedSprite2D:
		if _is_left:
			match starting_position:
				"LEFT":
					sprite.play()
				"RIGHT":
					sprite.play_backwards()
		else:
			match starting_position:
				"LEFT":
					sprite.play_backwards()
				"RIGHT":
					sprite.play()
	
	elif sprite is Sprite2D:
		sprite.flip_h = !sprite.flip_h
	
	_switched = true
	_is_left = !_is_left
	set_correct_collision()
	await get_tree().create_timer(TIME).timeout
	_switched = false
