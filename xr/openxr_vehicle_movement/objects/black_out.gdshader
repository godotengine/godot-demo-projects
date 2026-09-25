shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,unshaded,depth_test_disabled;
uniform vec4 albedo : source_color;

void vertex() {
	POSITION = vec4(VERTEX.xy * 2.0, -1.0, 1.0);
}

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
}
