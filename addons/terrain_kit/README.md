# Documentation

It is essential to know how to use the **addon**. In this file I will provide you the details on how to use it!

- [Starting](#starting)
    * ![pltf](/terrain_assets/BaseScripts/gate.svg) [Platforms](#platforms-)
    * ![prphzr](/terrain_assets/BaseScripts/tree_evergreen.svg) [Props and Hazards](#props-and-hazards-)

- [Specific](#specific)
    * ![brk_pltf](/terrain_assets/BreakPlatform/bone_fracture.svg) [Break Platform](#break-platform-)
    * ![mv_pltf](/terrain_assets/MovingPlatform/moving_platform.svg) [Moving Platform](#moving-platform-)
    * [Props Or Hazards](#props-or-hazards)
        - ![fan](/terrain_assets/Fan/fan.svg) [Fan](#fan-)

- [The additional](#the-additional)
    * ![lever](/terrain_assets/Lever/lever.svg) [Lever](#lever-)
    * ![PhBtn](/terrain_assets/PhysicalButton/push_button.svg) [Physical Button](#physical-button-)
    * [How to add them](#how-to-add-them)

- [Addon Details](#addon-details)

# Starting

The addon is based on 2 scripts that all nodes extend, [Platform](/terrain_assets/BaseScripts/PlatformBaseScript.gd) and [Prop or Hazard](/terrain_assets/BaseScripts/PropOrHazard.gd), that way most of the platforms and props are in need of the same setup!

## Platforms <img width="24" height="24" alt="pltf" src="/terrain_assets/BaseScripts/gate.svg"/>

This is the base setup for all generic platforms, inheriting from `PlatformBaseScript.gd`.

| Name | Default | Description | Type |
| :--- | :---: | :---: | ---: |
| Sprite | `null` | The Node2D that will be used for showing visuals. It MUST be a *Sprite2D* or *AnimatedSprite2D*. | [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html) |
| Collision Shape | `null` | The CollisionShape2D that will provide the collision for the platform. | [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) |
| Debug Color | `#0099b36b` | Custom debug color for the collision shape. | [Color](https://docs.godotengine.org/en/stable/classes/class_color.html) |
| Texture | `null` | The Texture2D of the terrain. Used if Sprite is a *Sprite2D*. | [Texture2D](https://docs.godotengine.org/en/stable/classes/class_texture2d.html) |
| Spriteframes | `null` | The SpriteFrames of the terrain. Used if Sprite is an *AnimatedSprite2D*. | [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html) |
| Texture Width | 32 | The texture's width. If greater than the original, it tiles a second texture. | [int](https://docs.godotengine.org/en/stable/classes/class_int.html) |
| Texture Height | 32 | The texture's height. If greater than the original, it tiles a second texture. | [int](https://docs.godotengine.org/en/stable/classes/class_int.html) |
| Enable (One Way) | `false` | If enabled, characters can jump through the platform from the specified direction. | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) |
| Way Pass Platform |NORTH| The cardinal direction from which the player can pass through the platform. | [enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string) |
| Enable (Circle) | `false` | If enabled, overrides the cardinal direction and allows arbitrary angle rotation for one-way collision. | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) |
| Degrees (Circle) | `0` | The exact angle in degrees for the one-way collision pass-through. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Is Attacking | `false` | If enabled, your platform has a Hazard (e.g., spikes). | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) |
| Damage | 5.0 | The health your hazard will reduce per hit. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Activate Time | 0.2 | The time (in seconds) that the hazard will wait until it activates. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Active Time | 0.2 | The time (in seconds) that the hazard will remain active and deadly. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Auto Size Attack | `true` | If false, the script will stop auto-sizing the hitbox so you can build it manually. | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) |
| Attack | `null` | The secondary CollisionShape2D used exclusively for the HitBox. | [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) |
| Location of Attack | NORTH| The cardinal direction your hazard will be facing. | [enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string) |
| Attack Reach | 3.0 | How far (in pixels) the attack will extend from the main platform. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Enable (Dir Circle)| `false` | If enabled, the location of attack is overwritten and defined by an orbital circle. | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) |
| Degrees (Dir Circle)| 0.0 | The exact orbital degrees on an XY axis system for hazard placement. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |

## Props and Hazards <img width="24" height="24" alt="prp_hzr" src="/terrain_assets/BaseScripts/tree_evergreen.svg"/>

This is the base setup for all generic obstacles, decorations, and traps, inheriting from `PropOrHazard.gd`.

| Name | Default | Description | Type |
| :--- | :---: | :---: | ---: |
| Sprite Still | `null` | The Sprite2D that holds the texture. It is useless if Visual Type is *Animated*. | [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html) |
| Sprite Animated | `null` | The AnimatedSprite2D that holds the texture. It is useless if Visual Type is *Still*. | [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) |
| Collision Shape | `null` | The CollisionShape2D that defines the physical collision of the Prop or Hazard. | [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) |
| Hitbox Component | `null` | The custom HitBox component used to deal damage. Not needed for standard Props. | [HitBox](/Components/hitbox_component.gd) -> [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html#area2d) |
| Hitbox Shape | `null` | The CollisionShape2D that defines the HitBox area of the Hazard. | [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) |
| Visual Type | Still | Choose whether this prop uses a still texture or an animated sequence. | [enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string) |
| Texture Still | `null` | The Texture2D used if Visual Type is set to *Still*. | [Texture2D](https://docs.godotengine.org/en/stable/classes/class_texture2d.html) |
| Texture Animated | `null` | The SpriteFrames used if Visual Type is set to *Animated*. | [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html) |
| Is Hazard | `false` | If enabled, this prop will deal damage to HurtBoxes. | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) |
| Damage | 10.0 | The amount of health points this hazard reduces. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Active Time (Pulse) | 0.0 | The time (in seconds) the hazard stays active. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Rest Time (Pulse) | 0.0 | The time (in seconds) the hazard waits before activating. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |

# Specific

## Break Platform <img width="24" height="24" alt="brk_pltf" src="/terrain_assets/BreakPlatform/bone_fracture.svg"/>

This node inherits from `Platform.gd` but acts as a fragile surface that crumbles when stood upon. 

| Name | Default | Description | Type |
| :--- | :---: | :---: | ---: |
| Break Time | 1.0 | The time (in seconds) the player can stand on the platform before it vanishes. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Area | `null` | The Area2D that detects if someone is standing on top of the platform. | [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) |
| Area Collision Shape | `null` | The CollisionShape2D used by the Area2D to detect the player. Automatically resized to match the platform. | [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) |

## Moving Platform <img width="24" height="24" alt="moving_pltf" src="/terrain_assets/MovingPlatform/moving_platform.svg"/>

This node inherits from `Platform.gd` and follows a specific path.
> [!NOTE]
> The node this script is attached to MUST be an [AnimatableBody2D](https://docs.godotengine.org/en/stable/classes/class_animatablebody2d.html#animatablebody2d).

| Name | Default | Description | Type |
| :--- | :---: | :---: | ---: |
| Speed | 150.0 | The speed at which the platform will move if acceleration is disabled. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Path | `null` | The Path2D the platform will follow. Must be assigned for movement to work. | [Path2D](https://docs.godotengine.org/en/stable/classes/class_path2d.html) |
| Acceleration Enable | `false` | If enabled, overrides speed and forces the platform to accelerate smoothly between ends. | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) |
| Travel Time | 3.0 | The exact time (in seconds) it takes to reach the end of the path. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Wait Time | 1.0 | The time (in seconds) the platform rests before moving again. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |

# Props Or Hazards

## Fan <img width="24" height="24" alt="fan" src="/terrain_assets/Fan/fan.svg"/>

This node inherits from `PropOrHazard.gd` and creates a directional wind zone.

| Name | Default | Description | Type |
| :--- | :---: | :--- | ---: |
| Air Area | `null` | The Area2D that covers the piece of land the Fan is hitting. | [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) |
| Direction of Air | UP (0) | In which direction the Fan is pushing the bodies that air is hitting. | [enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string) |
| Force | 1500.0 | Force of the air. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Non Physics Dampener | 0.15 | A value that is reducing the force for objects that have no gravity (e.g. Area2D). | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |

# The additional

> [!NOTE]
> The Nodes below are not used anywhere in the addon, but it is easy to add them [learn here how](#how-to-add-them)

## Lever <img width="24" height="24" alt="lever" src="/terrain_assets/Lever/lever.svg"/>

An interactable Area2D switch that can be toggled by the player.

| Name | Default | Description | Type |
| :--- | :---: | :--- | ---: |
| Starting Position | RIGHT | Defines whether the lever starts in the LEFT or RIGHT position. | [String](https://docs.godotengine.org/en/stable/classes/class_string.html) |
| Sprite | `null` | The visual node. It MUST be an *AnimatedSprite2D* or a *Sprite2D*. | [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html) |
| Collision | `null` | The physical bounds. MUST be a *CollisionPolygon2D* or *CollisionShape2D*. | [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html) |
| Texture Width | 32 | Used to calculate the offset of the collision when flipped. | [int](https://docs.godotengine.org/en/stable/classes/class_int.html) |
| Animation Play | RIGHT TO LEFT | If the sprite is an AnimatedSprite2D, sets the animation direction. | [enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string) |

## Physical Button <img width="24" height="24" alt="physical_button" src="/terrain_assets/PhysicalButton/push_button.svg"/>

A physics-driven button that depresses when objects are placed on top of it.

| Name | Default | Description | Type |
| :--- | :---: | :--- | ---: |
| Offset | 10.0 | How many pixels should the button go down. | [float](https://docs.godotengine.org/en/stable/classes/class_float.html) |
| Pressing Point | `null` | The Area2D that searches for a person above the button. | [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) |
| Sprite | `null` | The Sprite2D that holds your visual. | [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html) |
| Color | `#ffffff` (White) | The Color of the button. | [Color](https://docs.godotengine.org/en/stable/classes/class_color.html) |

### How to add them

The Interactables in this pack ([Lever](#lever-) and [PhysicalButton](#physical-button-)) are completely modular. They communicate with your game world using Godot's built-in [Signals](https://docs.godotengine.org/en/stable/engine_details/architecture/object_class.html#signals), making them perfect master switches for custom doors, traps, or moving platforms.

Both the [Lever](#lever-) and [Physical Button](#physical-button-) emit a `toggle(is_on: bool, node: Node2D)` signal. Here is how you can easily connect them to your own custom logic.

Step-by-Step Connection:

1. Build your level using the provided platforms and interactables.

2. Select your [Lever](#lever-) and [Physical Button](#physical-button-) in the [Scene Tree](https://docs.godotengine.org/en/stable/tutorials/performance/cpu_optimization.html#scenetree).

3. Open the Node tab next to the Inspector to view its signals.

4. Double-click the toggle signal.

5. Select the target node you want to control (e.g., a custom door or a modified MovingPlatform) and hit Connect.

#### Example Implementation:

If you want to create a platform that only moves when a lever is flipped, you don't need to rewrite the whole platform! Just create a new script that extends the base MovingPlatform, disable its default physics, and add a simple receiver function for the signal:

```GDScript
extends MovingPlatform

@export var trigger:Lever # The instance of the Lever, you can use PhysicalButton.

@export var trigger_travel_time: float = 3.0 # The time it takes to reach the other side.

var _trigger_tween: Tween

func _from_start() -> void:
    # Stop the platform from moving automatically.
    set_physics_process(false)
    # Check if signal is already connected.
    if not trigger.toggle.is_connected(_on_lever_toggled):
        #If not connect it.
        trigger.toggle.connect(_on_lever_toggled)

# Connect the Lever's 'toggle' signal to this function!
func _on_lever_toggled(is_on: bool, _node: Node2D) -> void:
    if _trigger_tween and _trigger_tween.is_valid():
        _trigger_tween.kill()
        
    _trigger_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    
    # If the lever is ON, move to the end of the path.
    # If the lever is OFF, return to the start of the path.
    var target_ratio: float = 1.0 if is_on else 0.0
    
    _trigger_tween.tween_property(
    _path_follow,
    "progress_ratio",
    target_ratio,
    trigger_travel_time)\
        .set_trans(Tween.TRANS_SINE)\
        .set_ease(Tween.EASE_OUT)
```

> [!TIP]
> This same signal logic can be used to open doors, activate boss fights, or spawn enemies. Just connect the toggle signal to any script in your game!

# Addon Details

I provided this addon with a **Base Platform** ![base_pltf](/terrain_assets/BasePlatform/grass.svg), a **Prop** ![prp](/terrain_assets/PropOrHazard/Prop/tree.svg) and a **Hazard** ![hzr](/terrain_assets/PropOrHazard/Hazard/bomb.svg) too! And Preset scenes for every asset, along with 3 components.

> [!TIP]
> Components are working but I would advise you to try and make your own.