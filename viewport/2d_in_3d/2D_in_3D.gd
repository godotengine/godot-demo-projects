extends Spatial

func _ready():
  # Get the viewport and clear it
  var viewport = get_node("Viewport")
  viewport.clear()
  # Let two frames pass to make sure the vieport's is captured
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  # Retrieve the texture and set it to the viewport quad
  get_node("Viewport_quad").material_override.albedo_texture = viewport.get_texture()
  
