# Dodge the Creeps

This is a simple game where your character must move
and avoid the enemies for as long as possible.

---

## 🎓 How to use this demo

This is a finished version of the game featured in the
["Your first 2D game"](https://docs.godotengine.org/en/latest/getting_started/first_2d_game/index.html)
tutorial in the documentation. For more details,
consider following the tutorial in the documentation.

Language: GDScript

Renderer: Compatibility

Note: There is a C# version available [here](https://github.com/godotengine/godot-demo-projects/tree/master/mono/dodge_the_creeps).

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/2712

---



**Reading the code? Want a quick overview?**  
→ Continue below ⬇️


---
 ## 🗺️ Architecture Overview

  Dodge the Creeps is a simple 2D game with 4 main components:

  - Main.gd (Node): Central orchestrator that manages game state, score, timers, and mob spawning
  - Player.gd (Area2D): Player character with movement controls and collision detection
  - HUD.gd (CanvasLayer): UI layer displaying score, messages, and start button
  - Mob.gd (RigidBody2D): Enemy entities with physics-based movement

  Game Flow: HUD emits start_game signal → Main starts timers → MobTimer spawns mobs randomly → Player collision      
  emits hit signal → Main triggers game over
  
 ---
 ## 📂 Files at a Glance

  player.gd - Player-controlled character (Area2D)
  - _process(): handles movement/input
  - start(pos): initializes position
  - _on_body_entered(): collision detection

  main.gd - Central game orchestrator (Node)
  - new_game(): starts new game
  - game_over(): stops all timers
  - _on_MobTimer_timeout(): spawns mobs
  - _on_ScoreTimer_timeout(): increments score

  hud.gd - User interface (CanvasLayer)
  - show_message(text): displays messages
  - show_game_over(): game over screen
  - update_score(score): updates score display
  - _on_StartButton_pressed(): starts game

  mob.gd - Enemies with physics (RigidBody2D)
  - _ready(): randomizes animation type
  - _on_VisibilityNotifier2D_screen_exited(): removes off-screen mob

  ---
  ## 🔑 Key Godot Concepts

  ### **1. Signals - Inter-node communication**

  #### player.gd:6
  signal hit

  #### hud.gd:5
  signal start_game
  Signals enable asynchronous communication between nodes without tight coupling.

  📖 https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html

   ### **2. Node Inheritance & Types**

  extends Area2D      # player.gd:2 - For collision detection
  extends Node        # main.gd:3 - Base container
  extends RigidBody2D # mob.gd:2 - For physics simulation
  extends CanvasLayer # hud.gd:2 - For separate UI rendering
  Each node type provides specific capabilities (physics, collision, rendering).

  📖 https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html

  ### **3. @export - Editor-exposed variables**

  #### player.gd:8
  @export var speed = 400

  #### main.gd:7
  @export var mob_scene: PackedScene
  Allows modifying values from the inspector without touching code.

  📖 https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html

  ### **4. await - Asynchronous flow control**

  #### hud.gd:25
  await $MessageTimer.timeout

  #### hud.gd:35
  await get_tree().create_timer(1).timeout
  Manages temporal sequences without blocking the game (Godot 4.x).

  📖 https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines

  ### **5. Path2D & Random Spawning**

  #### main.gd:53-57
  var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
  mob_spawn_location.progress = randi()
  Uses a path to spawn mobs randomly along screen edges.

  📖 https://docs.godotengine.org/en/stable/classes/class_path2d.html

  ### **6. Groups & call_group()**

  #### main.gd:28
  get_tree().call_group(&"mobs", &"queue_free")
  Calls a method on all nodes in a group (here: deletes all mobs).

  📖 https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html

  ### **7. set_deferred() - Physics engine safety**

  #### player.gd:87
  $CollisionShape2D.set_deferred(&"disabled", true)
  Defers modification until the collision engine is ready (avoids errors).

  📖 https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-set-deferred
  📖 https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-call-deferred

  ---
  ## 📝 Important Notes from Comments

  Player Movement (player.gd)
  - Delta Time (46-48): Ensures constant movement regardless of framerate
  - Normalization (36-38): Prevents diagonal movement from being faster
  - Y-axis inverted (27-28): Y-axis points down in Godot
  - Screen clamping (52): Keeps player within screen boundaries

  Main Game Logic (main.gd)
  - Rotation in radians (72-77): Godot uses radians internally
  - Dollar sign ($) (15): Shorthand for get_node()
  - Caret symbol (^) (52): Shorthand for ".." (go up one level)
  - queue_free() (27): Safe way to delete a node
  - Random direction (82-85): Adds variety to mob movement

  HUD Interface (hud.gd)
  - await for flow control (24-35): Sequential game flow technique
  - create_timer() (31-35): Creates temporary timer without adding node yourself in the editor

  Mob Behavior (mob.gd)
  - Random animations (9-14): Uses pick_random() for variety
  - Memory management (24-26): Frees mobs when off-screen
  - Cosmetic only (6-7): Different mob types are visual only

  ---

## Screenshots

![GIF from the documentation](https://docs.godotengine.org/en/latest/_images/dodge_preview.gif)

![Screenshot](screenshots/dodge.png)

## Copying

`art/House In a Forest Loop.ogg` Copyright &copy; 2012 [HorrorPen](https://opengameart.org/users/horrorpen), [CC-BY 3.0: Attribution](http://creativecommons.org/licenses/by/3.0/). Source: https://opengameart.org/content/loop-house-in-a-forest

Images are from "Abstract Platformer". Created in 2016 by kenney.nl, [CC0 1.0 Universal](http://creativecommons.org/publicdomain/zero/1.0/). Source: https://www.kenney.nl/assets/abstract-platformer

Font is "Xolonium". Copyright &copy; 2011-2016 Severin Meyer <sev.ch@web.de>, with Reserved Font Name Xolonium, SIL open font license version 1.1. Details are in `fonts/LICENSE.txt`.
