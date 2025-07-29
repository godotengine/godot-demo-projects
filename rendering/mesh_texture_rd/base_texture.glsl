#[vertex]
#version 450

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 uv;

layout(location = 0) out vec2 uv_interp;

layout(push_constant) uniform Data {
    mat4 xform;
};

void main() {
    uv_interp = uv;
    gl_Position = xform * vec4(position, 1.0);
}

#[fragment]
#version 450

layout(location = 0) in vec2 uv_interp;

layout(location = 0) out vec4 frag_color;

layout(set = 0, binding = 0) uniform sampler2D tex;

void main() {
    frag_color = texture(tex, uv_interp);
}
