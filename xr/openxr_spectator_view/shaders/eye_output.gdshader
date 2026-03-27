shader_type canvas_item;

uniform sampler2DArray xr_texture : source_color;
uniform float layer;

vec3 linear_to_srgb(vec3 color) {
	// Approximation from http://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html
	return max(vec3(1.055) * pow(color, vec3(0.416666667)) - vec3(0.055), vec3(0.0));
}

void vertex() {
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	UV.y = 1.0 - UV.y;
#endif
}

void fragment() {
	vec3 color = texture(xr_texture, vec3(UV, layer)).rgb;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	color = linear_to_srgb(color);
#endif
	COLOR.rgb = color;
	COLOR.a = 1.0;
}
