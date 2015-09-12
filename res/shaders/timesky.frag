#version 330

@{TextureSlots}

uniform float time;

in vec3 normal;
in vec2 texCoord;

layout(location = 0) out vec4 out_frag_color;

void main()
{
	vec4 color = texture(slot0, vec2(time, texCoord.y));
	out_frag_color = color;
}
