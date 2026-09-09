extends Node
class_name HealthComponent

signal on_change(current: float, max: float)
signal on_take_damage
signal on_died

@export var user: Node2D

enum PostDeath {DestroyNode, RestartScene}

var current_health: float

@export var health: float = 1.0

@export var post_death_action: PostDeath

@export var drop_on_death: PackedScene

func _ready() -> void:
	current_health = health
	if user != null: return
	user = get_parent()
	printerr('You forgot to place the user to the health component (', self, '). Automatically added the parent (', user, ') KOSSAINIS')

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return # Prevent multiple death signals
		
	current_health -= amount
	print(current_health)
	on_change.emit(current_health, health)
	on_take_damage.emit()
	
	if current_health <= 0:
		death()

func death() -> void:
	on_died.emit()
	print('died')
	if drop_on_death != null:
		var drop := drop_on_death.instantiate()
		drop.global_position = user.global_position
		get_tree().current_scene.call_deferred("add_child", drop)
		
	if post_death_action == PostDeath.DestroyNode:
		user.call_deferred("queue_free")
	elif post_death_action == PostDeath.RestartScene:
		get_tree().call_deferred("reload_current_scene")

func heal(amount: float) -> void:
	if current_health <= 0:
		return # Can't heal the dead
		
	current_health += amount
	if current_health > health:
		current_health = health
	
	on_change.emit(current_health, health)
