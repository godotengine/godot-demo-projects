shader_type canvas_item;
render_mode blend_premul_alpha;

uniform float radius = 5.0;
uniform float amount = 0.25;

void fragment() {
	float r = radius;
	vec2 ps = TEXTURE_PIXEL_SIZE;
	vec4 col = texture(TEXTURE, UV);
	vec4 glow = col;

	glow += texture(TEXTURE, UV + vec2(-r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(r, r) * ps);

	r *= 2.0;
	glow += texture(TEXTURE, UV + vec2(-r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(r, r) * ps);

	glow /= 17.0;
	glow *= amount;
	col.rgb *= col.a;

	COLOR = glow + col;
}
