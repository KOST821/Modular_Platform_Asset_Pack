extends Area2D
class_name HitBox

@export var user: Node2D

@export var damage:float = 9.0

func _ready() -> void:
	if get_parent() is Platform and user == null:
		user = get_parent()
		
	monitorable = false
	area_entered.connect(_on_damage_dealt)

func _on_damage_dealt(area: Area2D) -> void:
	if area is not HurtBox or not area.has_method('take_damage'):
		return
	if !user:
		printerr('No user added to HitBox.')
		return
	# Implicitly passes float damage now
	area.take_damage(damage)
