@tool
@icon("bomb.svg")
extends PropOrHazard
class_name Hazard

func _enter_tree() -> void:
	is_hazard = true
