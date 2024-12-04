shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);


void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}


void fragment() {
	vec4 albedo_tex = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}
