@icon("res://addons/terrain_kit/terrain_assets/one_way_collision_platform/motion_vector.svg")
extends Node
class_name PlatformFeelComponent

## Who is using this component.
@export var user: CharacterBody2D

## How much the player's movement is affected by slippery surfaces (0.0 = total ice, 1.0 = normal).
@export_range(0.0, 1.0) var slide_factor: float = 1.0

var previous_velocity: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	# We run this passively just to capture the velocity AFTER the user's move_and_slide() finishes
	if user:
		previous_velocity = user.velocity

# THIS IS THE MAGIC HOOK. The user's script MUST call this.
func apply_feel() -> void:
	if not user:
		printerr("CRITICAL: PlatformFeelComponent has no CharacterBody2D user assigned! KOSSAINIS")
		return
		
	# 1. HANDLE BOUNCE & ABSORBENT
	if user.is_on_floor() or user.is_on_wall() or user.is_on_ceiling():
		for i in user.get_slide_collision_count():
			var collision = user.get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider != null and "bounce" in collider:
				var platform_bounce = collider.get("bounce")
				var platform_absorbent = collider.get("absorbent")
				
				if platform_absorbent:
					# SPONGE EFFECT: Kills momentum upon impact, ignoring standard bounce
					user.velocity = user.velocity.move_toward(Vector2.ZERO, previous_velocity.length() * 0.5)
					break # Stop calculating other bounces
					
				elif platform_bounce > 0.0 and previous_velocity.length() > 50.0:
					# RUBBER EFFECT: Standard reflection calculation
					var bounce_vector = previous_velocity.bounce(collision.get_normal())
					user.velocity = bounce_vector * platform_bounce
					break 
					
	# 2. HANDLE FRICTION & ROUGH
	if user.is_on_floor():
		var floor_collider = user.get_last_slide_collision().get_collider()
		
		if floor_collider != null and "friction" in floor_collider:
			var platform_friction = floor_collider.get("friction")
			var platform_rough = floor_collider.get("rough")
			
			if platform_rough:
				# SANDPAPER EFFECT: Drastically increases deceleration, killing slides
				user.velocity.x = lerp(user.velocity.x, 0.0, 0.5)
			elif platform_friction < 1.0:
				# ICE EFFECT: Slippery ground, making it hard to stop
				user.velocity.x = lerp(user.velocity.x, 0.0, platform_friction * slide_factor)
