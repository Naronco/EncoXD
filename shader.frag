#version 330
out vec4 out_frag_color;

in vec2 texCoord;

void main(void)
{
	out_frag_color = vec4(texCoord, 0, 1);
}
