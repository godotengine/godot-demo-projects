# Custom Resource Plugin Demo

This plugin demo shows one way to create a custom Resource type in Godot.
For more information, see the documentation on [making plugins](https://docs.godotengine.org/en/latest/tutorials/plugins/editor/making_plugins.html)
and [resources](https://docs.godotengine.org/en/latest/tutorials/scripting/resources.html).

A custom Resource type:

* Derives from [Resource](https://docs.godotengine.org/en/latest/classes/class_resource.html) (or a subclass).

* Shows up in the "New Resource" dialog and in the type list when assigning a `Resource`-typed `@export` property.

* Can hold data via `@export` properties that show up in the inspector.

* Can be saved to and loaded from `.tres`/`.res` files.

The way it works in this plugin is using `add_custom_type` and `remove_custom_type` in the plugin script file.
Using this method you can specify any name, base type, script, and (optionally) icon for your custom Resource.

There is also another way to add custom Resource types, which is using the `class_name` keyword in a script,
or [using the `[GlobalClass]` attribute above a class declaration in C#](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_global_classes.html).
Both approaches work for Resources just as they do for Nodes.
