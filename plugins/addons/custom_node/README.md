# Custom Node Plugin Demo

This plugin demo shows one way to create a custom node type in Godot.
For more information, see this documentation article: https://docs.godotengine.org/en/latest/tutorials/plugins/editor/making_plugins.html#a-custom-node

A custom node type:

* Derives from an existing node type.

* Shows up in the type list when adding a new node.

* Has a script attached to add new behavior.

* May have a custom icon.

The way it works in this plugin is using the `add_custom_type` and `remove_custom_type` in the plugin script file.
Using this method you can specify any name, base type, script, and icon for your custom node.

There is also another way to add custom node types, which is using the `class_name` keyword in a script,
or [using the `[GlobalClass]` attribute above a class declaration in C#](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_global_classes.html).
