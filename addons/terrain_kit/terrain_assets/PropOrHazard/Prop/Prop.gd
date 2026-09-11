@tool
@icon("tree.svg")
extends PropOrHazard
class_name Prop

func _enter_tree() -> void:
	is_hazard = false
