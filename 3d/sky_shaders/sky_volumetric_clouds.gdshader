// Cloud Raymarching based on:
// A. Schneider. “The Real-Time Volumetric Cloudscapes Of Horizon: Zero Dawn”.
// ACM SIGGRAPH. Los Angeles, CA: ACM SIGGRAPH, 2015. Web. 26 Aug. 2015.

shader_type sky;
render_mode use_half_res_pass, use_quarter_res_pass;

uniform sampler3D worlnoise : filter_linear_mipmap, repeat_enable;
uniform sampler3D perlworlnoise : filter_linear_mipmap, repeat_enable;
uniform sampler2D cloud_map : filter_linear_mipmap, repeat_enable;

uniform float cloud_density : hint_range(0.01, 0.99) = 0.05;
uniform float cloud_coverage : hint_range(0.0, 0.99) = 0.25;
uniform float cloud_time_scale : hint_range(0.0, 20.0) = 1.0;
uniform float cloud_time_offset : hint_range(0.0, 1000.0, 0.1) = 0.0;
uniform vec2 cloud_direction = vec2(0.9, 1.0);
uniform vec2 cloud_steps_range = vec2(96.0, 54.0);
uniform float clouds_screen_lod : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec4 cloud_modulate : source_color = vec4(1.0);
uniform vec2 cloud_camera_position_mult = vec2(0.1, 0.2);
uniform float cloud_camera_height;

uniform float rayleigh : hint_range(0, 64) = 2.0;
uniform vec4 rayleigh_color : source_color = vec4(0.26, 0.41, 0.58, 1.0);
uniform float mie : hint_range(0, 1) = 0.005;
uniform float mie_eccentricity : hint_range(-1, 1) = 0.8;
uniform vec4 mie_color : source_color = vec4(0.63, 0.77, 0.92, 1.0);

uniform float turbidity : hint_range(0, 1000) = 10.0;
uniform float sun_disk_scale : hint_range(0, 360) = 1.0;
uniform vec4 ground_color : source_color = vec4(1.0);
uniform float exposure : hint_range(0, 128) = 0.1;

uniform sampler2D space_emit : hint_default_transparent, filter_linear;
uniform vec4 space_emit_color : source_color = vec4(1.0);
uniform float space_emit_angle : hint_range(0.0, 1.0, 0.001);
uniform float space_emit_strength = 1.0;

const vec3 UP = vec3(0.0, 1.0, 0.0);

// Approximately earth sizes.
const float GROUND_RADIUS = 6000000.0;
const float SKY_BOTTOM_RADIUS = 6001500.0; // Bottom of cloud layer.
const float SKY_TOP_RADIUS = 6004000.0; // Top of cloud layer.

// Sun constants.
const float SOL_SIZE = 0.00872663806;
const float SUN_ENERGY = 1000.0;

// Optical length at zenith for molecules.
const float rayleigh_zenith_size = 8.4e3;
const float mie_zenith_size = 1.25e3;

float parabola(float x, float k) {
    return pow(4.0 * x * (1.0 - x), k);
}

// From: https://www.shadertoy.com/view/4sfGzS.
// Credit to Inigo Quilez.
float hash(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// Utility function that maps a value from one range to another (similar to GDScript's `remap()`).
float remap(float original_value, float original_min,  float original_max, float new_min,  float new_max) {
	return new_min + (((original_value - original_min) / (original_max - original_min)) * (new_max - new_min));
}

// Phase function.
float henyey_greenstein(float cos_theta, float g) {
	const float k = 0.0795774715459;
	return k * (1.0 - g * g) / (pow(1.0 + g * g - 2.0 * g * cos_theta, 1.5));
}

// Simple analytic sky.
// In a real project, you should use a texture to improve performance.
vec3 atmosphere(vec3 eye_dir, vec2 coords, float space) {
	float zenith_angle = clamp(dot(UP, normalize(LIGHT0_DIRECTION)), -1.0, 1.0);
	float sun_energy = max(0.0, 1.0 - exp(-((PI * 0.5) - acos(zenith_angle)))) * SUN_ENERGY * LIGHT0_ENERGY;
	float sun_fade = 1.0 - clamp(1.0 - exp(LIGHT0_DIRECTION.y), 0.0, 1.0);

	// Rayleigh coefficients.
	float rayleigh_coefficient = rayleigh - (1.0 * (1.0 - sun_fade));
	vec3 rayleigh_beta = rayleigh_coefficient * rayleigh_color.rgb * 0.0001;
	// Mie coefficients from Preetham.
	vec3 mie_beta = turbidity * mie * mie_color.rgb * 0.000434;

	// Optical length.
	float zenith = acos(max(0.0, dot(UP, eye_dir)));
	float optical_mass = 1.0 / (cos(zenith) + 0.15 * pow(93.885 - degrees(zenith), -1.253));
	float rayleigh_scatter = rayleigh_zenith_size * optical_mass;
	float mie_scatter = mie_zenith_size * optical_mass;

	// Light extinction based on thickness of atmosphere.
	vec3 extinction = exp(-(rayleigh_beta * rayleigh_scatter + mie_beta * mie_scatter));

	// In scattering.
	float cos_theta = dot(eye_dir, normalize(LIGHT0_DIRECTION));

	float rayleigh_phase = (3.0 / (16.0 * PI)) * (1.0 + pow(cos_theta * 0.5 + 0.5, 2.0));
	vec3 betaRTheta = rayleigh_beta * rayleigh_phase;

	float mie_phase = henyey_greenstein(cos_theta, mie_eccentricity);
	vec3 betaMTheta = mie_beta * mie_phase;

	vec3 Lin = pow(sun_energy * ((betaRTheta + betaMTheta) / (rayleigh_beta + mie_beta)) * (1.0 - extinction), vec3(1.5));
	// Hack from <https://github.com/mrdoob/three.js/blob/master/examples/jsm/objects/Sky.js>.
	Lin *= mix(vec3(1.0), pow(sun_energy * ((betaRTheta + betaMTheta) / (rayleigh_beta + mie_beta)) * extinction, vec3(0.5)), clamp(pow(1.0 - zenith_angle, 5.0), 0.0, 1.0));

	// Hack in the ground color.
	Lin  *= mix(ground_color.rgb, vec3(1.0), smoothstep(-0.1, 0.1, dot(UP, eye_dir)));

	// Solar disk and out-scattering.
	float sunAngularDiameterCos = cos(SOL_SIZE * sun_disk_scale);
	float sunAngularDiameterCos2 = cos(SOL_SIZE * sun_disk_scale*0.5);
	float sundisk = smoothstep(sunAngularDiameterCos, sunAngularDiameterCos2, cos_theta);
	vec3 L0 = (sun_energy * 1900.0 * extinction) * sundisk * LIGHT0_COLOR;

	// Add night-time sky.
	vec2 space_coords = vec2(fract(coords.x + space_emit_angle), coords.y);
	vec4 space_tex = texture(space_emit, space_coords * vec2(1.0, 2.0));
	vec3 space_color = space_tex.rgb * space_tex.a * space_emit_color.rgb * space_emit_color.a;

	L0 += space_color * 5000.0 * space_emit_strength * extinction * space;

	vec3 color = (Lin + L0) * 0.04;
	color = pow(color, vec3(1.0 / (1.2 + (1.2 * sun_fade))));
	color *= exposure;
	return color;
}

float get_height_fraction_for_point(float in_position) {
	float height_fraction = (in_position - SKY_BOTTOM_RADIUS) / (SKY_TOP_RADIUS - SKY_BOTTOM_RADIUS);
	return clamp(height_fraction, 0.0, 1.0);
}

vec4 mix_gradients(float cloud_type) {
	const vec4 STRATUS_GRADIENT = vec4(0.02, 0.05, 0.09, 0.11);
	const vec4 STRATOCUMULUS_GRADIENT = vec4(0.02, 0.2, 0.48, 0.625);
	const vec4 CUMULUS_GRADIENT = vec4(0.01, 0.0625, 0.78, 1.0);
	float stratus = 1.0f - clamp(cloud_type * 2.0, 0.0, 1.0);
	float stratocumulus = 1.0f - abs(cloud_type - 0.5) * 2.0;
	float cumulus = clamp(cloud_type - 0.5, 0.0, 1.0) * 2.0;
	return STRATUS_GRADIENT * stratus + STRATOCUMULUS_GRADIENT * stratocumulus + CUMULUS_GRADIENT * cumulus;
}

float density_height_gradient(float height_frac, float cloud_type) {
	vec4 cloud_gradient = mix_gradients(cloud_type);
	return smoothstep(cloud_gradient.x, cloud_gradient.y, height_frac) - smoothstep(cloud_gradient.z, cloud_gradient.w, height_frac);
}

float intersect_sphere(vec3 pos, vec3 dir, float r) {
    float a = dot(dir, dir);
    float b = 2.0 * dot(dir, pos);
    float c = dot(pos, pos) - (r * r);
	float d = sqrt((b * b) - 4.0 * a * c);
	float p = -b - d;
	float p2 = -b + d;
    return max(p, p2) / (2.0 * a);
}

// Returns density at a given point.
// Heavily based on method from Schneider.
float density(vec3 pip, vec3 weather, float mip) {
	vec3 p = pip;
	p.x += 10.0 * cloud_time_offset * cloud_time_scale;
	float height_fraction = get_height_fraction_for_point(length(p));
	vec4 n = textureLod(perlworlnoise, p.xyz * 0.00008, mip - 2.0);
	float fbm = n.g * 0.625 + n.b * 0.25 + n.a * 0.125;
	float g = density_height_gradient(height_fraction, weather.r);
	float base_cloud = remap(n.r, -(1.0-fbm), 1.0, 0.0, 1.0);
	float weather_coverage = cloud_coverage * weather.b;
	base_cloud = remap(base_cloud * g, 1.0 - weather_coverage, 1.0, 0.0, 1.0);
	base_cloud *= weather_coverage;
	p.xy -= 40.0 * cloud_time_offset * cloud_time_scale;
	vec3 hn = textureLod(worlnoise, p * 0.001, mip).rgb;
	float hfbm = hn.r * 0.625 + hn.g * 0.25 + hn.b * 0.125;
	hfbm = mix(hfbm, 1.0 - hfbm, clamp(height_fraction * 4.0, 0.0, 1.0));
	base_cloud = remap(base_cloud, hfbm * 0.4 * height_fraction, 1.0, 0.0, 1.0);
	return pow(clamp(base_cloud, 0.0, 1.0), (1.0 - height_fraction) * 0.8 + 0.5);
}

vec4 march(vec3 pos, vec3 end, vec3 dir, int depth) {
	const vec3 RANDOM_VECTORS[6] = {
		vec3(0.38051305, 0.92453449, -0.02111345),
		vec3(-0.50625799, -0.03590792, -0.86163418),
		vec3(-0.32509218, -0.94557439, 0.01428793),
		vec3(0.09026238, -0.27376545, 0.95755165),
		vec3(0.28128598, 0.42443639, -0.86065785),
		vec3(-0.16852403, 0.14748697, 0.97460106)
	};

	float T = 1.0;
	float alpha = 0.0;
	float ss = length(dir);
	dir = normalize(dir);
	vec3 p = pos + hash(pos * 10.0) * ss;
	const float t_dist = SKY_TOP_RADIUS - SKY_BOTTOM_RADIUS;
	float lss = (t_dist / 36.0);
	vec3 ldir = normalize(LIGHT0_DIRECTION);
	vec3 L = vec3(0.0);
	int count = 0;
	float t = 1.0;

	float cos_theta = dot(ldir, dir);
	// Stack multiple phase functions to emulate some backscattering.
	float phase = max(max(henyey_greenstein(cos_theta, 0.6), henyey_greenstein(cos_theta, (0.4 - 1.4 * ldir.y))), henyey_greenstein(cos_theta, -0.2));

	// Precalculate sun and ambient colors.
	// This should really come from a uniform or texture for performance reasons.
	vec3 atmosphere_sun = atmosphere(LIGHT0_DIRECTION, vec2(0), 0) * LIGHT0_ENERGY * ss * 0.1;
	vec3 atmosphere_ambient = atmosphere(normalize(vec3(1.0, 1.0, 0.0)), vec2(0), 0);
	vec3 atmosphere_ground = atmosphere(normalize(vec3(1.0, -1.0, 0.0)), vec2(0), 0);

	const float WEATHER_SCALE = 0.00006;
	float time = 0.003 * cloud_time_offset * cloud_time_scale;
	vec2 weather_pos = vec2(time * cloud_direction.x, time * cloud_direction.y);

	for (int i = 0; i < depth; i++) {
		p += dir * ss;
		vec3 weather_sample = texture(cloud_map, p.xz * WEATHER_SCALE + 0.5 + weather_pos).xyz;
		float height_fraction = get_height_fraction_for_point(length(p));

		t = density(p, weather_sample, 0.0);
		float dt = exp(-cloud_density*t*ss);
		T *= dt;
		vec3 lp = p;
		float lt = 1.0;
		float cd = 0.0;

		if (t > 0.0) {
			// Calculate lighting, but only when we're in the cloud.
			float lheight_fraction = 0.0;
			for (int j = 0; j < 6; j++) {
				lp += (ldir + RANDOM_VECTORS[j] * float(j)) * lss;
				lheight_fraction = get_height_fraction_for_point(length(lp));
				vec3 lweather = texture(cloud_map, lp.xz * WEATHER_SCALE + 0.5 + weather_pos).xyz;
				lt = density(lp, lweather, float(j));
				cd += lt;
			}

			// Take a single distant sample.
			lp = p + ldir * 18.0 * lss;
			lheight_fraction = get_height_fraction_for_point(length(lp));
			vec3 lweather = texture(cloud_map, lp.xz * WEATHER_SCALE + 0.5).xyz;
			lt = pow(density(lp, lweather, 5.0), (1.0 - lheight_fraction) * 0.8 + 0.5);
			cd += lt;

			// Captures the direct lighting from the sun.
			float beers = exp(-cloud_density * cd * lss);
			float beers2 = exp(-cloud_density * cd * lss * 0.25) * 0.7;
			float beers_total = max(beers, beers2);

			vec3 ambient = mix(atmosphere_ground, vec3(1.0), smoothstep(0.0, 1.0, height_fraction)) * cloud_density * mix(atmosphere_ambient, vec3(1.0), 0.4) * (LIGHT0_DIRECTION.y);
			alpha += (1.0 - dt) * (1.0 - alpha);
			L += (ambient + beers_total * atmosphere_sun * phase * alpha) * T * t;
		}
	}
	return clamp(vec4(L, alpha), 0.0, 1.0);
}

vec4 clouds(vec3 dir, vec3 background, vec2 steps_in, float screen_x, vec3 camera) {
	vec4 col;
	if (dir.y > 0.0) {
		vec3 camera_position = vec3(0.0, GROUND_RADIUS, 0.0) + vec3(camera.x * cloud_camera_position_mult.x, camera.y * cloud_camera_position_mult.y + cloud_camera_height, camera.z * cloud_camera_position_mult.x);
		vec3 start = camera_position + dir * intersect_sphere(camera_position, dir, SKY_BOTTOM_RADIUS);
		vec3 end = camera_position + dir * intersect_sphere(camera_position, dir, SKY_TOP_RADIUS);
		float shell_distance = (length(end - start));
		// Take fewer steps towards horizon and screen sides.
		float steps = mix(steps_in.y, steps_in.x, clamp(dot(dir, vec3(0.0, 1.0, 0.0)) * mix(1.0, parabola(screen_x, 0.75), clouds_screen_lod), 0.0, 1.0));
		vec3 ray_step = dir * shell_distance / steps;
		vec4 volume = march(start, end, ray_step, int(steps));
		volume *= cloud_modulate;

		// Draw cloud shape.
		col = vec4(background * (1.0 - volume.a) + volume.xyz, 1.0);
		// Blend distant clouds into the sky.
		col.xyz = mix(clamp(col.xyz, vec3(0.0), vec3(1.0)), clamp(background, vec3(0.0), vec3(1.0)), smoothstep(0.6, 1.0, 1.0-dir.y));
		col = volume;
	}

	// Draw to quarter-resolution buffer for reflections.
	// Draw to half-resolution buffer for main sky.
	return col;
}

vec4 clouds_post(vec3 direction, vec4 volume, vec3 background) {
	// Draw background at full resolution pass.
	vec4 col;

	if (direction.y > 0.0) {
		// Draw cloud shape.
		col = vec4(background * (1.0 - volume.a) + volume.xyz, 1.0);
		// Blend distant clouds into the sky.
		col.xyz = mix(clamp(col.xyz, vec3(0.0), vec3(1.0)), clamp(background, vec3(0.0), vec3(1.0)), smoothstep(0.6, 1.0, 1.0 - direction.y));
	} else {
		col = vec4(atmosphere(direction, vec2(0), 0), 1.0);
	}

	return col;
}

void sky() {
	vec3 background = atmosphere(EYEDIR, SKY_COORDS, 1.0);

	if (AT_HALF_RES_PASS && !AT_CUBEMAP_PASS) {
		vec4 col = clouds(EYEDIR, background, cloud_steps_range, SCREEN_UV.x, POSITION);
		COLOR = col.rgb;
		ALPHA = col.a;
	} else if (AT_QUARTER_RES_PASS && AT_CUBEMAP_PASS) {
		COLOR = clouds_post(EYEDIR, clouds(EYEDIR, background, vec2(15, 10), SCREEN_UV.x, POSITION), background).rgb;
		ALPHA = 1.0;
	} else if (AT_CUBEMAP_PASS) {
		COLOR = QUARTER_RES_COLOR.rgb;
	} else {
		COLOR = clouds_post(EYEDIR, vec4(HALF_RES_COLOR), background).rgb;
		ALPHA = 1.0;
	}
}
