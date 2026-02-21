// This shader is used for the shadow-only water plane. A separate MeshInstance3D and shader
// are required, as an opaque material must be used for GeometryInstance3D's
// Shadows Only `cast_shadow` mode to work.
//
// The shadow plane is placed slightly above the main water plane to compensate
// for shadow bias.
shader_type spatial;

// Should match the constants in `water.gdshader`.
const float WAVE_AMPLITUDE = 0.125;
const float WAVE_SPEED = 1.3;

void vertex() {
	// Make the surface wave (same as in `water.gdshader`).
 	VERTEX.y += -WAVE_AMPLITUDE + (sin(VERTEX.x + TIME * WAVE_SPEED) + sin(VERTEX.z * 2.0 + TIME * WAVE_SPEED)) * WAVE_AMPLITUDE;
}
