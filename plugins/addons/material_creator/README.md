# Material Creator Plugin Demo

This plugin demo contains a custom material creator
interface using a custom dock in the editor.

Custom docks are made of Control nodes, they run in the
editor, and any behavior must be done through `tool` scripts.
For more information, see this documentation article:
https://docs.godotengine.org/en/latest/tutorials/plugins/editor/making_plugins.html#a-custom-dock

This plugin allows you to specify color, metallic, and
roughness values, and then use it as a material.

You can apply this material directly to Spatial
nodes by selecting them and then clicking "Apply".
This shows how a plugin can interact closely with the
editor, manipulating nodes the user selects.

Alternatively, you can also save the material to
a file, and then load it back into the plugin later.
