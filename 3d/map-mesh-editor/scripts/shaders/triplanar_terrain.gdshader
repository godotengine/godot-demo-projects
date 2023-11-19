shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

// Magic that puts VERTEX/NORMAL in world coordinates instead of local
render_mode world_vertex_coords;

varying vec3 triplanar_pos;
varying vec3 power_normal;
varying vec3 world_normal;
varying vec3 object_normal;
varying float height;

uniform float grass_spread: hint_range(0.0, 1.0, 0.05);

uniform vec4 earth : source_color;
uniform sampler2D texture_earth;

uniform vec4 grass : source_color;
uniform sampler2D texture_grass;

void vertex() {
	world_normal = vec3(0, 1.0, 0);
	object_normal = NORMAL;
	
	power_normal = pow(abs(NORMAL), vec3(10.0)); // vec3(10.0)
	power_normal = normalize(power_normal);
	
	triplanar_pos = VERTEX.xyz * vec3(1.0, -1.0, 1.0) * 0.01;
	
	height = VERTEX.y;
}


vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}


void fragment() {
	// Earth
	vec4 earth_tex = triplanar_texture(texture_earth, power_normal, triplanar_pos);
	ALBEDO = earth_tex.rgb * earth.rgb;
	
	// Grass
	vec4 grass_tex = triplanar_texture(texture_grass, power_normal, triplanar_pos);
	float m = dot(object_normal, world_normal);
	m = clamp(m, 0.0, 1.0);
	if (m > grass_spread) m = 1.0;
	else m *= 0.5;
	
	ALBEDO = mix(earth_tex.rgb * earth.rgb, grass_tex.rgb * grass.rgb, m);
	
}
