shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;

const float SCROLL_SPEED = 0.04;

void fragment() {
	vec2 noise1_uv = UV + vec2(SCROLL_SPEED) * TIME;
	COLOR = texture(noise1, noise1_uv);
	COLOR.rgb += 0.3 * texture(noise2, UV * 4.0 - vec2(texture(noise1, noise1_uv * 0.3).xy * 0.015) * TIME * 2.0).r;
}
