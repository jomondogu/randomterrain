R"(
#version 330 core
in vec3 vposition;

out vec3 uvw;

uniform mat4 M;
uniform mat4 V;
uniform mat4 P;

void main() {
    // Cubemaps follow a LHS coordinate system
    uvw = vec3(vposition.x, -vposition.z, -vposition.y);
    gl_Position = P*V*M*vec4(10*vposition, 1.0);
}
)"
