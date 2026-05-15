shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D audiosample : repeat_enable;
const float cfac = 4.0;
const float mfac = 2.0;
const float mdisp = 0.166667;
const float mthick = 0.05;
const float mtiltfac = 0.125;

void fragment() {
	vec4 b = texture(audiosample, UV + vec2(-(UV.y - 0.5) * mtiltfac, 0.0));
	vec4 c = texture(audiosample, UV + vec2((UV.y - 0.5) * mtiltfac, 0.0));
	float s = (b.r + c.g) / 2.0;
	COLOR = vec4(0.1 + max(s, 0.0) * cfac, 0.1, 0.1 + max(-s, 0.0) * cfac, 1.0);

	vec4 a = texture(audiosample, UV);
	float dr = abs(UV.y * 2.0 - 1.0 - (a.r + mdisp) * mfac);
	float dg = abs(UV.y * 2.0 - 1.0 - (a.g - mdisp) * mfac);

	if (dg < mthick) {
		COLOR = vec4(1.0, 1.0, 0.9, 1.0);
	} else if (dr < mthick) {
		COLOR = vec4(0.8, 0.8, 0.9, 1.0);
	}
}
