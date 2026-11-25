shader_type spatial;
render_mode blend_add, depth_draw_never, unshaded, cull_disabled;

uniform sampler2D texture_albedo : filter_linear_mipmap_anisotropic, repeat_disable;
uniform float brightness : hint_range(0.0, 10.0, 0.001) = 1.0;

void fragment() {
	vec4 texture_albedo_sampled = texture(texture_albedo, UV);
	ALBEDO = COLOR.rgb * texture_albedo_sampled.rgb * brightness;
	ALPHA = COLOR.a * texture_albedo_sampled.a;
}
