# Plugin Demos

This contains multiple plugin demos, all placed in a project for convenience.

Please see the documentation for editor plugins:
https://docs.godotengine.org/en/latest/tutorials/plugins/editor/index.html

Language: GDScript

Renderer: GLES 2

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/585

# How does it work?

This project contains 4 plugins:

* The custom node plugin shows how to create a custom node type
  using `add_custom_type`. [More info](addons/custom_node).

* The material import plugin shows how to make a plugin handle importing
  a custom file type (mtxt). [More info](addons/material_import_plugin).

* The material creator plugin shows how to add a custom dock with some
  simple functionality. [More info](addons/material_creator).

* The main screen plugin is a minimal example of how to create a plugin
  with a main screen. [More info](addons/main_screen).

To use these plugins in another project, copy any of these
folders to the `addons/` folder in a Godot project, and then
enable them in the project settings menu.

For example, the path would look like: `addons/custom_node`

Plugins can be distributed and installed from the UI.
If you make a zip that contains the folder, Godot will recognize
it as a plugin and will allow you to install it.

This can be done via the terminal: `zip -r custom_node.zip custom_node/*`
