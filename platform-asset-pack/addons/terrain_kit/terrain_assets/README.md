# 🗺️ Terrain Kit for Godot 4
Terrain Kit is a custom-built, drag-and-drop Godot plugin designed for rapid level design. It provides a suite of smart platforms, hazards, and props that require absolutely zero coding from the level designer. Everything is controlled dynamically through the Godot Inspector.

## ⚠️ The Golden Rule
NEVER use the Godot Scale Tool (the resizing handles or the S key) on any platform.
Scaling physics bodies will permanently break the game's physics engine. If you need to make a platform larger, use the texture_width and texture_height sliders in the Inspector. The platform will automatically tile its artwork and resize its collision box safely.

## ⚙️ Setup
For hazards to work, your player character must have a script that extends `Area2D` with the `class_name` set to `HurtBox` and a `take_damage` function. 

Create a new script, attach it to an `Area2D` on your player, and copy-paste the following:

```
extends Area2D
class_name HurtBox

func take_damage(_damage: float) -> void:
    pass
```

## 🛠️ How to Spawn Platforms
I have built a custom control panel directly into the editor so you never have to go digging through files.

In your Scene Tree, click the folder or node where you want the new platform to go (e.g., click your LevelGeometry folder).

Go to the Terrain Kit dock.

Click the button for the platform you want. It will instantly spawn into your level, perfectly organized inside the folder you selected.

## 🧱 The Platform Guide  <img src="addons/terrain_kit/terrain_assets/base_platform/tilemap.svg" height="40" align="center">
When you click on any spawned platform, look at the Inspector panel on the right side of your screen to configure it.

### 1. Base Platform
What it is: Standard, unmoving ground, walls, and ceilings.

How to size it: Type your desired size into texture_width and texture_height. The art will seamlessly repeat to fill the space.

Platform Feel: You can change how the surface reacts to the player. Lower the Friction slider to 0.0 to create slippery ice levels, or raise the Bounce slider to create trampoline surfaces.

### 2. Moving Platform
What it is: A platform that patrols along a custom-drawn track.

How to draw the track: Click the platform in your Scene Tree. A new toolbar will appear at the top center of the Godot workspace. Click the Add Point tool (a pen with a green plus icon) and click in the 2D viewport to draw the exact path it should follow.

Movement Settings: Set the speed in the Inspector.

Acceleration: If you want smooth, AAA-style pacing, check the acc_acceleration_enable box. You can then tweak travel_time (how long the trip takes) and wait_time (how long it pauses before reversing).

### 3. Break Platform
What it is: A crumbling floor that drops the player.

The "Doormat" Rule: This platform is smart. It will only break if you step on top of it. If you hit your head on the bottom, or slide down the side walls, it remains perfectly solid.

Timing: Use the time_to_break slider to dictate exactly how many seconds the player has to jump off before the platform shatters.

### 4. One-Way Platform
What it is: A platform you can jump up through from underneath, but land solidly on top of.

Directional Settings: By default, it acts like a floor. If you want to make a special wall that the player can dash through from the left but not the right, change the way_pass_platform dropdown to WEST, EAST, or SOUTH.

Angled Slopes: If you are building a hill, check circle_enable and type your slope angle into circle_degrees.

### 5. Props & Hazards
What it is: Decorative physics objects (trees, rocks) or active hazards (spikes, fire traps).

Visuals: Use the Type dropdown to switch between "Still" (a single image) and "Animated" (a looping animation like a torch).

Auto-Collisions: Add a CollisionShape2D node to it. Choose a Box, Capsule, or Circle shape. Change the dimensions in the Inspector, and the prop will automatically do the math to snap the collision box perfectly around your art.

Turning it into a Hazard:

Check the is_attacking box to enable the damage hitbox.

Use the Direction settings to snap the attack hitbox to the NORTH, SOUTH, EAST, or WEST of the prop.

Adjust dir_attack_reach to make the hazard stick out further.

Note on Damage: For the hazard to hurt the player, the player must have an Area2D node attached to them with a script class named HurtBox that contains a take_damage(amount) function.

Hazard Timers: Hazards can turn on and off automatically! Adjust the activate_time (how long it stays safe) and active_time (how long it deals damage).
