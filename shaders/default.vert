#version 330

uniform mat4 modelview;
uniform mat4 projection;
uniform mat4 normalmatrix;

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_tex;
layout(location = 2) in vec3 in_normal;

out vec2 texCoord;
out vec3 normal;

void main()
{
	gl_Position = projection * modelview * vec4(in_position, 1);

	texCoord = in_tex;
	normal = (normalmatrix * vec4(in_normal, 1)).xyz;
}
