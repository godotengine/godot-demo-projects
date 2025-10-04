# Material Creator Plugin Demo

This plugin demo contains a custom material creation dock
inside the Godot editor.

Custom docks are made of Control nodes, they run in the
editor, and any behavior must be done through `tool` scripts.
For more information, see this documentation article:
https://docs.godotengine.org/en/latest/tutorials/plugins/editor/making_plugins.html#a-custom-dock

## Features
- Adjust albedo color, metallic and rouphness values interactively.
- Apply the generated material to selected 3D nodes in the editor.
- Save and load materials in two ways:
	- `.silly_mat`: Custom Godot Resource type, handled by custom saver/loader
	included in the plygin.
	- `.mtxt`: Plain-text format. Useful for external editing or as an 
	interchange format.
	- `.tres`: Standard Godot resource format (works without the custom
	loader).

## Implementation notes
- `.silly_mat` format is registered through `SillyMatFormatSaver` and
`SillyMatFormatLoader` in the plugin.
- Custm docks are built from `Control` nodes and run as `@tool` scripts.
