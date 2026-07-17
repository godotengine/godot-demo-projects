shader_type spatial;
render_mode blend_mix, cull_back, unshaded, shadow_to_opacity;

// The hole punch shader is a trick where we are drawing a fully transparent surface
// that does write to the depth buffer.
// This results in an optical occluder.
// When used for our scene anchor geometry, this allows us to occlude virtual objects that are
// behind real world geometry.

uniform vec4 albedo : source_color = vec4(1.0);

void fragment() {
	ALBEDO = albedo.rgb;
}
