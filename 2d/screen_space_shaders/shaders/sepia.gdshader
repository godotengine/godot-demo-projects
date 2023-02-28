shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec4 base : source_color;

void fragment() {
	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	float v = dot(c, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	COLOR.rgb = base.rgb * v;
}
