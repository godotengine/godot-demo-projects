shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D audiosample : repeat_enable;
const float cfac = 4.0;
const float mfac = 2.0;
const float mdisp = 0.166667;
const float mthick = 0.05;

void fragment() {
  vec4 a = texture(audiosample, UV);
  float dr = abs(UV.y*2.0 - 1.0 - (a.r + mdisp)*mfac);
  float dg = abs(UV.y*2.0 - 1.0 - (a.g - mdisp)*mfac);
  COLOR = vec4(0.1+max(a.r,0.0)*cfac, 0.1, 0.1+max(-a.r,0.0)*cfac, 1.0);
  if (dg < mthick)
    COLOR = vec4(1.0,1.0,0.9,1.0);
  else if (dr < mthick)
    COLOR = vec4(0.8,0.8,0.9,1.0);
}
