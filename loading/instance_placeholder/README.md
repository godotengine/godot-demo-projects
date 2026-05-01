# Instance Placeholder

This demo shows how to use [InstancePlaceholder](https://docs.godotengine.org/en/latest/classes/class_instanceplaceholder.html)
to defer loading a sub-scene until it is actually needed
(the **lazy loading pattern**).

In the editor, the `HeavySlot` node under `Main` is an instance of
`heavy_scene.tscn` that has been marked as **Load As Placeholder**
(right-click on the instance in the Scene dock → *Load As Placeholder*).
At runtime, `HeavySlot` is replaced with an `InstancePlaceholder` node:
the heavy scene's resources stay on disk and the script never runs
until we explicitly ask for them.

Pressing the **Load Heavy Scene** button calls
`placeholder.create_instance(true)`, which loads `heavy_scene.tscn`,
instantiates it as a child of `Main`, and frees the placeholder.
The new node takes the placeholder's name (`HeavySlot`) and position
in the parent's children list, so existing `$HeavySlot` lookups keep
working after the swap.

## When to use this pattern

* A scene contains optional content (a settings panel, a debug overlay,
  a tutorial popup) that the player rarely opens.
* A level streams large sub-scenes only when the player approaches them.
* You want the placeholder to be configured visually in the editor,
  without paying the runtime cost on every load.

For background loading of resources from disk, see the `load_threaded`
demo in this folder, which complements this pattern.

Language: GDScript

Renderer: Compatibility
