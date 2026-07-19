@tool
extends EditorPlugin

var dock: VBoxContainer

func _enter_tree() -> void:
	# 1. Create the UI container
	dock = VBoxContainer.new()
	dock.name = "Terrain Kit"
	
	# 2. Create the buttons
	_create_button("Add Base Platform", "res://addons/terrain_kit/terrain_assets/base_platform/basic_platform.tscn")
	_create_button("Add Moving Platform", "res://addons/terrain_kit/terrain_assets/moving_platform/moving_platform.tscn")
	_create_button("Add Break Platform", "res://addons/terrain_kit/terrain_assets/brake_platform/break_platform.tscn")
	_create_button("Add One-Way Platform", "res://addons/terrain_kit/terrain_assets/one_way_collision_platform/one_way_platform.tscn")
	_create_button("Add Prop or Hazard", "res://addons/terrain_kit/terrain_assets/props/props.tscn")
	
	# 3. Add the UI to the Godot Editor's left panel
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, dock)

func _exit_tree() -> void:
	# Clean up the UI when the plugin is turned off
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()

func _create_button(button_text: String, scene_path: String) -> void:
	var btn = Button.new()
	btn.text = button_text
	# Connect the button press to the instancing function, passing the specific scene path
	btn.pressed.connect(_spawn_scene.bind(scene_path))
	dock.add_child(btn)

func _spawn_scene(path: String) -> void:
	# 1. Get the absolute root of the open level (Needed for saving!)
	var root = EditorInterface.get_edited_scene_root()
	if root == null:
		printerr("Terrain Kit: Please open a level scene before adding platforms.")
		return
		
	var scene: PackedScene = load(path)
	if scene == null:
		printerr("Terrain Kit: Failed to load scene. Path might be broken.")
		return
		
	var instance = scene.instantiate()
	
	# 2. Figure out where to put it
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	var parent_node: Node
	
	if selected_nodes.is_empty():
		# Fallback: If they haven't clicked anything, just drop it on the root
		parent_node = root
	else:
		# Use the first thing they have selected in the tree
		parent_node = selected_nodes[0]
		
	# 3. Add it to the tree under the selected node
	parent_node.add_child(instance)
	
	# 4. CRITICAL: Tell Godot to save this node as part of the main level
	# The owner MUST be the root, regardless of who the parent is.
	instance.owner = root
