#version 330

uniform vec3 l_direction;

in vec3 normal;
in vec2 texCoord;

layout(location = 0) out vec4 out_frag_color;

void main()
{
	out_frag_color = vec4(normal, 1);
}
