shader_type spatial;
render_mode unshaded;

// The coordinates of every point in a quadrant of a 4 pixel radius
const vec2 kernel3[4] = {vec2(0,0), vec2(0,1), vec2(1,0), vec2(1,1)};
const vec2 kernel4[13] = {vec2(0,0), vec2(0,1), vec2(0,2), vec2(0,3), vec2(1,0), vec2(1,1), vec2(1,2), vec2(1,3), vec2(2,0), vec2(2,1), vec2(2,2), vec2(3,0), vec2(3,1)};
const vec2 kernel5[25] = {vec2(0,0), vec2(0,1), vec2(0,2), vec2(0,3), vec2(0,4), vec2(1,0), vec2(2,0), vec2(3,0), vec2(4,0), vec2(1,1), vec2(1,2), vec2(1,3), vec2(1,4), vec2(2,0), vec2(2,1), vec2(2,2), vec2(2,3), vec2(2,4), vec2(3,0), vec2(3,1), vec2(3,2), vec2(3,3), vec2(4,0), vec2(4,1), vec2(4,2)};
const vec2 kernel6[41] = {vec2(0,0), vec2(0,1), vec2(0,2), vec2(0,3), vec2(0,4), vec2(0,5), vec2(0,6), vec2(1,0), vec2(1,1), vec2(1,2), vec2(1,3), vec2(1,4), vec2(1,5), vec2(1,6), vec2(2,0), vec2(2,1), vec2(2,2), vec2(2,3), vec2(2,4), vec2(2,5), vec2(2,6), vec2(3,0), vec2(3,1), vec2(3,2), vec2(3,3), vec2(3,4), vec2(3,5), vec2(4,0), vec2(4,1), vec2(4,2), vec2(4,3), vec2(4,4), vec2(4,5), vec2(5,0), vec2(5,1), vec2(5,2), vec2(5,3), vec2(5,4), vec2(6,0), vec2(6,1), vec2(6,2)};

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;

varying mat4 CAMERA;

// Get the mean colour and standard deviation of a single quadrant around the current pixel
vec4 quadrant(sampler2D tex, vec2 uv, float xDir, float yDir, vec2 resolution) {
	vec3 pointTotal = vec3(0,0,0);

	float maxPoint = 0.0;
	float minPoint = 255.0;
	for (int i=0; i<kernel6.length(); i++) {
		// Apply the direction modifiers to the coordinate
		vec2 uvOffset = (kernel6[i]*vec2(xDir, yDir))/resolution;
		vec3 point = texture(tex, uv + uvOffset).xyz;

		// Changing this value calculation has interesting effects on the colour groupings
		float value = max(max(point.x, point.y), point.z);
		pointTotal += point;
		maxPoint = max(maxPoint, value);
		minPoint = min(minPoint, value);
	}

	// Standard deviation can be quickly approximated and the loss of accuracy does not diminish the effect
	float standardDeviation = maxPoint-minPoint;

	// Return a vec4 to get round not being able to return structs or arrays
	return vec4(pointTotal.x, pointTotal.y, pointTotal.z, standardDeviation);
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
	CAMERA = INV_VIEW_MATRIX;
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_pos = world.xyz / world.w;
	
	vec2 resolution = vec2(textureSize(screen_texture, 0));

	// Get the mean and standard deviation of all quadrants around the current pixel
	vec4 quadrants[4] = {
		quadrant(screen_texture, SCREEN_UV, -1.0, -1.0, resolution),
		quadrant(screen_texture, SCREEN_UV, 1.0, -1.0, resolution),
		quadrant(screen_texture, SCREEN_UV, -1.0, 1.0, resolution),
		quadrant(screen_texture, SCREEN_UV, 1.0, 1.0, resolution)
	};

	// Find the quadrant with the lowest standard deviation
	float minStandardDeviation = 255.0;
	vec3 colour = vec3(0,0,0);
	for (int i=0; i<=3; i++) {
		if (quadrants[i].a < minStandardDeviation) {
			minStandardDeviation = quadrants[i].a;
			colour = quadrants[i].xyz;
		}
	}

	// Use the mean colour of the lowest deviation quadrant
	ALBEDO.xyz = colour/float(kernel6.length());
}