shader_type canvas_item;

uniform vec4 base: hint_color;
uniform sampler2D grain;
uniform float grain_strength = 0.3;
uniform sampler2D vignette;
uniform float fps = 12.0;
uniform float stretch = 0.5;
uniform float flashing = 0.01;

float make_grain(float time, vec2 uv) {
	vec2 ofs = vec2(sin(41.0 * time * sin(time * 123.0)), sin(27.0 * time * sin(time * 312.0)));
	return texture(grain, (uv + mod(ofs, vec2(1.0, 1.0))) * stretch).r;
}

void fragment() {
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	
	//float v = max(c.r, max(c.g, c.b));
	float v = dot(c, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	//v *= v;
	
	float f = 1.0 / fps;
	float g = make_grain(TIME - mod(TIME, f), UV);
	g = max(g, make_grain(TIME - mod(TIME, f) + f, UV) * 0.5);
	g = max(g, make_grain(TIME - mod(TIME, f) + f * 2.0, UV) * 0.25);
	
	COLOR.rgb = base.rgb * v - vec3(g) * grain_strength;
	COLOR.rgb *= texture(vignette, UV).r;
	float ft = TIME * 0.002;
	COLOR.rgb += vec3(sin(75.0 * ft * sin(ft * 123.0))) * flashing;
}
