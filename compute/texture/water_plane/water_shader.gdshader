shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 albedo : source_color;
uniform float metalic : hint_range(0.0, 1.0, 0.1) = 0.8;
uniform float roughness : hint_range(0.0, 1.0, 0.1) = 0.2;
uniform sampler2D effect_texture;
uniform vec2 effect_texture_size;

varying vec2 uv_tangent;
varying vec2 uv_binormal;

void vertex() {
	vec2 pixel_size = vec2(1.0, 1.0) / effect_texture_size;

	uv_tangent = UV + vec2(pixel_size.x, 0.0);
	uv_binormal = UV + vec2(0.0, pixel_size.y);
}

void fragment() {
	float f1 = texture(effect_texture, UV).r;
	float f2 = texture(effect_texture, uv_tangent).r;
	float f3 = texture(effect_texture, uv_binormal).r;

	vec3 tangent = normalize(vec3(1.0, 0.0, f2 - f1));
	vec3 binormal = normalize(vec3(0.0, 1.0, f3 - f1));
	NORMAL_MAP = normalize(cross(binormal, tangent)) * 0.5 + 0.5;

	ALBEDO = albedo.rgb;
	METALLIC = metalic;
	ROUGHNESS = roughness;
	SPECULAR = 0.5;
}
