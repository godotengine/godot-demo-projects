shader_type canvas_item;

uniform float rotation = 3.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 rel = uv - vec2(0.5, 0.5);
	float angle = length(rel) * rotation;
	mat2 rot = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	rel = rot * rel;
	uv = clamp(rel + vec2(0.5,0.5), vec2(0.0, 0.0), vec2(1.0, 1.0));
	COLOR.rgb = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
}
