shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

varying vec3 triplanar_pos;

uniform sampler2D r_texture : source_color;
uniform sampler2D g_texture : source_color;
uniform sampler2D b_texture : source_color;

uniform vec3 color : source_color;

void vertex() {
	triplanar_pos = VERTEX.xyz * vec3(1.0, -1.0, 1.0) * 0.01;
}

void fragment() {
	vec4 sample = (texture(r_texture, triplanar_pos.xz) * COLOR.r)
		+ (texture(g_texture, triplanar_pos.xz) * COLOR.g)
		+ (texture(b_texture, triplanar_pos.xz) * COLOR.b);
	ALBEDO = sample.rgb * color;
}
