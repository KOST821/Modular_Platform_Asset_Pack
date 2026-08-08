extends Area2D
class_name HurtBox

@export var user:Node2D

func _ready() -> void:
	if user == null:
		user = get_parent()
		print_rich('[color=YELLOW] There was no user placed. The parent got automaticlly placed, KOSSAINIS')
	monitoring = false

func take_damage(damage:int)->void:
	if ! "health_component" in user:
		printerr("You MUST add a variable health_component to the user which is a HealthComponent, try adding this to the top of your script: <<@export var health_component:HealthComponent>> KOSSAINIS")
		return
	if user.health_component != null:
		user.health_component.take_damage(damage)
	else:
		printerr('You forgot to place the health component to the parent (',self,'). Automaticlly added the parent (',user,') KOSSAINIS')
