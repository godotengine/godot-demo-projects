shader_type spatial;
render_mode cull_disabled, specular_schlick_ggx;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

uniform float waveAmount : hint_range(0.1, 1.5) = 0.8;
uniform float waveSpeed : hint_range(0.1, 10) = 1.0;

uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.6;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.2;

uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

uniform vec3 edge_color: source_color;
uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;

float generateOffset(float x, float z, float a, float b, float time) {
	float radsX = ((mod(x + z * x * a, waveAmount) / waveAmount) + (time * waveSpeed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radsZ = ((mod(b * (z * x + x * z), waveAmount) / waveAmount) + (time * waveSpeed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;
	
	return waveAmount * 0.5 * (sin(radsZ) + cos(radsX));
}

vec3 waveDistortion(vec3 vertex, float time) {
	float x = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float y = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float z = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);
	return vertex + vec3(x, y, z);
}

void vertex() {
	VERTEX = waveDistortion(VERTEX, TIME);
}

float fresnel(float amt, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amt);
}

float rim(float depth) {
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void fragment() {
	float depth_tex = texture(depth_texture, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_tex + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth + VERTEX.z + depth_offset) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);
	
	vec3 screen_color = textureLod(screen_texture, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
	vec3 c = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
	
	float z_depth = rim(texture(depth_texture, SCREEN_UV).x);
	float z_pos = rim(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(color, color2, fresnel);
	
	vec3 depth_color_adj = mix(edge_color, c, step(edge_scale, z_dif));
	
	ALBEDO = clamp(surface_color + depth_color_adj, vec3(0.0), vec3(1.0));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX))) * 1.2;
}
