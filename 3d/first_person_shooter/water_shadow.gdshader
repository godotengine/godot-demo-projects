shader_type spatial;

const float WAVE_AMPLITUDE = 0.125;
const float WAVE_SPEED = 1.3;

void vertex() {
	// Make the surface wave.
 	VERTEX.y += -WAVE_AMPLITUDE + (sin(VERTEX.x + TIME * WAVE_SPEED) + sin(VERTEX.z * 2.0 + TIME * WAVE_SPEED)) * WAVE_AMPLITUDE;
}
