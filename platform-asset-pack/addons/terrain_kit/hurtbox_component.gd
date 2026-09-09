extends Area2D
class_name HurtBox

@export var health_counter: Node
@export_placeholder("take_damage") var method: String

func _ready() -> void:
	if health_counter == null:
		push_error('HurtBox error: There was no health_counter placed on ', get_parent().name)
		# Removed get_tree().quit() so the editor doesn't crash on testing
		return
	
	if method == "":
		method = "take_damage"
		push_warning("HurtBox warning: No method written! The placeholder was automatically added.")
		
	monitoring = false

func take_damage(damage: float) -> void:
	if !health_counter:
		printerr("HurtBox error: You MUST assign a node to the health_counter slot in the inspector. KOSSAINIS")
		return
		
	if health_counter.has_method(method):
		health_counter.call_deferred(method, damage)
	else:
		push_error("The assigned health_counter does not have a method named: ", method)
