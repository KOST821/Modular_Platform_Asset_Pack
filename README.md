# 🗺️ Terrain Kit for Godot 4

Terrain Kit is a custom-built, drag-and-drop Godot plugin designed for rapid level design. It provides a suite of smart platforms, hazards, and props that require absolutely zero coding from the level designer.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Prerequisites & Setup](#prerequisites--setup)
- [How to Spawn Platforms](#how-to-spawn-platforms)
- [Platform Guide](#platform-guide)
- [Props & Hazards](#props--hazards)
- [The Golden Rule](#the-golden-rule)
- [Troubleshooting](#troubleshooting)

## ⚡ Quick Start

1. **Add the plugin** to your Godot project's `addons/` folder
2. **Enable it** in Project → Project Settings → Plugins
3. **Set up HurtBox** (see [Prerequisites](#prerequisites--setup))
4. **Open the Terrain Kit dock** and start spawning platforms!

## ✨ Features

- 🏗️ **5 Smart Platform Types** – Base, Moving, Breaking, One-Way, and more
- 🎨 **Drag-and-Drop Editor** – No file digging required
- ⚙️ **Inspector-Driven Configuration** – Adjust all settings in real-time
- 🎭 **Props & Hazards** – Decorative objects and attack hitboxes
- 🧮 **Auto-Physics** – CollisionShape2D handling built-in
- 🎬 **Animation Support** – Still or looping animations
- 🎛️ **Movement Tracks** – Custom patrol paths for moving platforms
- 🏃 **Physics Feel Control** – Adjust friction and bounce per platform

---

## Prerequisites & Setup

### HurtBox Requirement

For hazards to work, your player character **must** have an Area2D-based script with the `HurtBox` class name and a `take_damage()` function.

**Create a new script and attach it to an Area2D on your player:**

```gdscript
extends Area2D
class_name HurtBox

func take_damage(_damage: float) -> void:
    pass
```

---

## 🛠️ How to Spawn Platforms

1. In your **Scene Tree**, click the folder where you want the platform (e.g., `LevelGeometry`)
2. Open the **Terrain Kit dock** (usually on the right side of the Godot editor)
3. Click the button for the platform type you want
4. The platform instantly spawns, perfectly organized in your selected folder
5. Configure it using the **Inspector** panel on the right

---

## 🧱 Platform Guide

When you click any spawned platform, the **Inspector** panel displays all configuration options.

### 1. Base Platform <img src="https://raw.githubusercontent.com/KOST821/asset-terrain-pack/main/platform-asset-pack/addons/terrain_kit/terrain_assets/base_platform/tilemap.svg" width="28" height="28" align="center" style="margin-left: 8px; margin-right: 0;">

**What it is:** Standard, unmoving ground, walls, and ceilings.

**How to size it:**
- Type your desired size into `texture_width` and `texture_height`
- The art will seamlessly repeat to fill the space

**Platform Feel:**
- **Friction** – Lower to 0.0 for slippery ice levels
- **Bounce** – Raise for trampoline-like surfaces

---

### 2. Moving Platform <img src="https://raw.githubusercontent.com/KOST821/asset-terrain-pack/main/platform-asset-pack/addons/terrain_kit/terrain_assets/moving_platform/moving_platform.svg" width="28" height="28" align="center" style="margin-left: 8px; margin-right: 0;">

**What it is:** A platform that patrols along a custom-drawn track.

**How to draw the track:**
1. Click the platform in your Scene Tree
2. A new toolbar appears at the top center of the workspace
3. Click the **Add Point tool** (pen with green plus icon)
4. Click in the viewport to place waypoints
5. The platform will patrol between them

**Movement Settings:**
- **speed** – How fast the platform travels
- **acc_acceleration_enable** – Check for smooth, AAA-style pacing
- **travel_time** – How long the trip takes
- **wait_time** – How long it pauses before reversing direction

---

### 3. Break Platform <img src="https://raw.githubusercontent.com/KOST821/asset-terrain-pack/main/platform-asset-pack/addons/terrain_kit/terrain_assets/brake_platform/skull.svg" width="28" height="28" align="center" style="margin-left: 8px; margin-right: 0;">

**What it is:** A crumbling floor that drops the player.

**The "Doormat" Rule:** This platform is smart—it only breaks when stepped on from the top. Hit it from the bottom or slide down the side and it stays solid.

**Timing:**
- Use `time_to_break` to set how many seconds the player has to jump off before the platform shatters

---

### 4. One-Way Platform <img src="https://raw.githubusercontent.com/KOST821/asset-terrain-pack/main/platform-asset-pack/addons/terrain_kit/terrain_assets/one_way_collision_platform/motion_vector.svg" width="28" height="28" align="center" style="margin-left: 8px; margin-right: 0;">

**What it is:** Jump up through from underneath, but land solidly on top.

**Directional Settings:**
- By default, acts as a floor
- Change `way_pass_platform` dropdown to configure directional pass-through (e.g., "WE" = pass West-East)

**Angled Slopes:**
- Check `circle_enable`
- Set `circle_degrees` to your desired slope angle
- Perfect for building hills

---

### 5. Props & Hazards <img src="https://raw.githubusercontent.com/KOST821/asset-terrain-pack/main/platform-asset-pack/addons/terrain_kit/terrain_assets/props%26hazards/tree.svg" width="28" height="28" align="center" style="margin-left: 8px; margin-right: 0;">

**What it is:** Decorative physics objects (trees, rocks) or active hazards (spikes, fire traps).

**Visuals:**
- **Type** dropdown: Choose "Still" (single image) or "Animated" (looping animation like a torch)

**Auto-Collisions:**
1. Add a **CollisionShape2D** node to the prop
2. Choose a shape: Box, Capsule, or Circle
3. Adjust dimensions in the Inspector
4. The prop automatically snaps the collision box

**Turning it into a Hazard:**

- Check **is_attacking** to enable the damage hitbox
- Use **Direction settings** to snap the attack hitbox to NORTH, SOUTH, EAST, or WEST
- Adjust **dir_attack_reach** to extend the hazard further

**Note on Damage:** The hazard requires the player to have an Area2D with a `HurtBox` class that contains a `take_damage(amount)` function.

**Hazard Timers:**
- **activate_time** – How long it stays safe before dealing damage
- **active_time** – How long it deals damage before going safe again

---

## ⚠️ The Golden Rule

### NEVER use the Godot Scale Tool on any platform.

The resizing handles or the **S key** will **permanently break** the game's physics engine.

**If you need to make a platform larger:**
1. Use the `texture_width` and `texture_height` sliders in the Inspector
2. The platform will automatically scale with the correct physics

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Physics feels broken or wobbly** | Did you use the Godot Scale Tool? Use `texture_width`/`texture_height` instead |
| **Hazards don't hurt the player** | Make sure the player has an Area2D with a `HurtBox` class and `take_damage()` function |
| **Platforms not spawning** | Ensure the Terrain Kit plugin is enabled in Project Settings → Plugins |
| **Moving platform won't move** | Check that you've drawn at least 2 waypoints using the Add Point tool |
| **One-Way platform doesn't work** | Verify `way_pass_platform` is set to the correct direction |
| **Props falling through the ground** | Add a CollisionShape2D to the prop and set an appropriate shape |

---

## 💡 Tips & Best Practices

- **Performance:** Limit the number of physics bodies; static platforms are more efficient than moving ones
- **Visual Consistency:** Use the same platform type for similar surfaces to maintain aesthetic cohesion
- **Animation Smoothness:** Enable `acc_acceleration_enable` on moving platforms for fluid motion
- **Level Testing:** Playtest frequently to catch physics issues early

---

**Made with ❤️ for Godot 4**
