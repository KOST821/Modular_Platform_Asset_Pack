extends Area2D
class_name HitBox

@export var user:Node2D

func _ready() -> void:
	if "platform_uid11299087490986" in get_parent() and user == null:
		user = get_parent()
		
	monitorable = false
	
	area_entered.connect(_on_damage_dealt)

func _on_damage_dealt(area: Area2D) -> void:
	if area is not HurtBox or not area.has_method('take_damage'):
		return
	if !user:
		printerr('No user added, KOSSAINIS')
		return
	area.take_damage(user.damage)
