shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_texture : source_color;
uniform bool use_vertex_uv;
uniform bool swap_uv;
uniform vec2 scale_uv = vec2(1.0, 1.0);
uniform vec2 offset_uv;

void vertex() {
	UV = VERTEX.xy * 0.5 + 0.5;
	if (swap_uv) {
		float swap = UV.x;
		UV.x = UV.y;
		UV.y = swap;
	}
	UV = offset_uv + UV * scale_uv;
}

void fragment() {
	vec4 color = texture(albedo_texture, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
