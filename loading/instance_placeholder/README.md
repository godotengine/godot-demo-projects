# Instance Placeholder

This demo shows how to use [InstancePlaceholder](https://docs.godotengine.org/en/latest/classes/class_instanceplaceholder.html)
to defer loading a sub-scene until it is actually needed.

The `HeavySlot` node under `Main` is set to "Load As Placeholder" in the editor,
so it loads as an `InstancePlaceholder` at runtime instead of the actual scene.
Pressing the button calls `placeholder.create_instance(true)` to load the heavy
scene's resources, instantiate them, and free the placeholder in one call.

Language: GDScript

Renderer: Compatibility
