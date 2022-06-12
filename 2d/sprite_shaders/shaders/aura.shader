shader_type canvas_item;
render_mode blend_premul_alpha;

// This shader only works properly with premultiplied alpha blend mode.
uniform float aura_width = 2.0;
uniform vec4 aura_color: hint_color;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;
	float maxa = col.a;
	float mina = col.a;

	a = texture(TEXTURE, UV + vec2(0.0, -aura_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(0.0, aura_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-aura_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(aura_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	col.rgb *= col.a;

	COLOR = col;
	COLOR.rgb += aura_color.rgb * (maxa - mina);
}
