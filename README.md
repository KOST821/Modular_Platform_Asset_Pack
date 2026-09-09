# 🧱 Godot 4 Modular Platform Asset Pack

Welcome to the **Modular Platform Asset Pack**! This toolkit is built on a highly scalable, component-based architecture designed for Godot 4. It allows level designers to create complex, interactive, and hazardous platforms without writing a single line of code.

---

## 🚀 Getting Started

Every platform in this pack inherits from a core `@abstract` tool script (`Platform`). This means all sizing, hazard logic, and tiling happen automatically in the editor.

1. **Do not scale nodes manually in the 2D viewport!** Always use the `Texture Width` and `Texture Height` sliders in the inspector. The script handles the rest safely.
2. Ensure Godot's `@tool` scripts are running. If platforms aren't updating visually in the editor, click **Project -> Reload Current Project**.

---

## 🧩 Platform Types

### 1. Base Platform (`BasePlatform`)
The standard workhorse. Use this for walls, floors, and static floating platforms. It relies entirely on the base class, making it extremely cheap on physics performance.

### 2. Breaking Platform (`BreakPlatform`)
A fragile platform that crumbles shortly after a physics body stands on it.
*   **Break Time:** The delay (in seconds) before the platform vanishes or plays its breaking animation.
*   **Area / Area Collision Shape:** Automatically resizes and positions itself on top of the physical platform to detect players.

### 3. Moving Platform (`MovingPlatform`)
A platform that patrols along a `Path2D` node using Godot's safe `AnimatableBody2D` physics. 

To create it, first create an `AnimatableBody2D` in the tree and just attach the code, otherwise it will be buggy.

*   **Path:** **Must** be assigned in the inspector. Draw your path in the editor, and the platform will follow it seamlessly.
*   **Speed:** Constant movement speed for linear platforms.
*   **Acceleration (acc_):** Overrides constant speed to provide smooth, sine-wave easing between path points. Includes customizable travel and wait times.

---

## ⚙️ Core Features (Available on ALL Platforms)

### 🎨 Visuals & Sizing
*   **Texture:** Assign a `Sprite2D` texture or an `AnimatedSprite2D` SpriteFrames resource.
*   **Width / Height:** Drag these sliders to automatically tile standard sprites and perfectly size the collision boxes without warping pixels.

### 🛡️ One-Way Collisions
*   Enable **One Way Collision** to let players jump up through the bottom of the platform.
*   Choose a cardinal direction (`NORTH`, `WEST`, `SOUTH`, `EAST`) or enable **Circle** to set a custom, precise angle. Hitbox dimensions automatically swap to prevent distortion when rotated.

### ⚔️ Hazards & Attacks
Turn any platform into a deadly trap by checking **Is Attacking**.
*   **Auto-Size Attack:** Uncheck this if you want to manually build a custom-shaped hazard. Leave it checked to let the script mathematically align and perfectly fit the hazard to the platform's edges.
*   **Direction / Reach:** Position the hazard on any side of the platform, or orbit it precisely using the Circle settings.
*   **Timers (Activate / Active):** Create pulsing traps (e.g., spikes that pop in and out) by setting the active and rest durations. 

---

## 🧰 The Component System

This pack includes a completely decoupled damage system. You can drop these onto platforms, enemies, or destructible crates with zero coding required!


*   **`HealthComponent`:** Add this to any node that can die. Handles max health, current health, and death behaviors (Destroy Node, Restart Scene, or spawn an item).
*   **`HurtBox`:** Add this as an `Area2D` child to a node. Link it to a `HealthComponent` in the inspector. It securely receives damage.
*   **`HitBox`:** Add this as an `Area2D` child to deal damage. Export your desired `damage` amount in the inspector. When it overlaps a `HurtBox`, damage is dealt instantly.

> [!TIP]
> These work but it is suggested to create your own or find other ones! 

# Interactables
**(Lever & PhysicalButton):** Puzzle elements designed to trigger events. The lever features smooth animation toggling, while the physical button uses tween-driven physics to physically compress when stepped on by a player or object.