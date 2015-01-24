#version 330

uniform sampler2D slot0;
uniform vec4 color;

in vec2 texCoord;

layout(location = 0) out vec4 out_frag_color;

void main()
{
	out_frag_color = texture(slot0, texCoord) * color;
}
