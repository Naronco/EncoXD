#version 330

out vec4 out_frag_color;

in vec2 texCoord;
in vec3 normal;

void main(void)
{
	out_frag_color = vec4(vec3(texCoord, 1) * dot(normal, normalize(vec3(1, 1, 1))), 1);
}
