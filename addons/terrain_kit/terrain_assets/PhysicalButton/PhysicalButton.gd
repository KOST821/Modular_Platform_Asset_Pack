@tool
@icon("push_button.svg")
## A button that is pressed only if an Object is above it.
extends Node2D
class_name PhysicalButton

## Emitted when pressed.
signal pressed(physical_button:Node2D)
## Emitted when released.
signal released(physical_button:Node2D)
## Emitted when toggled.
signal toggle(is_on:bool, physical_button:Node2D)

## How many pixels should the button go down.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var offset:float = 10.0

## The [Area2D] that searches for a person above the button.
@export var pressing_point: Area2D:
	set(area):
		pressing_point = area
		update_configuration_warnings()

## The [Sprite2D] that holds your visual.
@export var sprite: Sprite2D:
	set(sprite2d):
		sprite = sprite2d
		update_configuration_warnings()
		_update_color(color)

## The [Color] of the button.
@export var color:Color = Color.WHITE:
	set(selected):
		color = selected
		_update_color(selected)

var is_pressed:bool = false

var _tween:Tween

var started_pos:Vector2

var _bodies_pressing:Array[CollisionObject2D] = []

func _get_configuration_warnings() -> PackedStringArray:
	if sprite == null:
		return['You do not have a Sprite2D added in "sprite".']
	
	if pressing_point == null:
		return['You do not have a Area2D added in "pressing_point".']
	
	return []

func _ready() -> void:
	
	started_pos = sprite.position
	
	pressing_point.body_entered.connect(body_enter)
	pressing_point.body_exited.connect(body_exit)
	
	if not Engine.is_editor_hint():
		_update_color(color)

func _update_color(color_to_add:Color) -> void:
	if not sprite: return
	sprite.modulate = color_to_add

func body_enter(body:Node2D) -> void:
	if body is CollisionObject2D and is_pressed: 
		_bodies_pressing.append(body)
		return
	elif body is CollisionObject2D:
		is_pressed = true
		_bodies_pressing.append(body)
		pressed.emit(self)
		toggle.emit(true, self)
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		var target_pos:float = started_pos.y + offset
		_tween.tween_property(sprite,"position:y",target_pos,1.0)

func body_exit(body:Node2D) -> void:
	if not is_pressed:
		return
	elif _bodies_pressing.has(body): _bodies_pressing.erase(body)
	
	_bodies_pressing = _bodies_pressing.filter(func(b): return is_instance_valid(b))
	
	if ! _bodies_pressing.is_empty():
		return
	is_pressed = false
	_bodies_pressing.clear()
	released.emit(self)
	toggle.emit(false, self)
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var target_pos:float = started_pos.y
	_tween.tween_property(sprite,"position:y",target_pos,1.0)
