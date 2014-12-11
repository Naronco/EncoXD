#version 330

@{TextureSlots}

in vec3 normal;
in vec2 texCoord;

layout(location = 0) out vec4 out_frag_color;

vec4 tex(sampler2D slot)
{
	return texture(slot, texCoord);
}

vec4 tex(sampler2D slot, float x, float y)
{
	return texture(slot, texCoord * vec2(x, y));
}

void main()
{
	vec4 color = @{Color:vec4(1, 0, 1, 1)};
	if(color.a < 0.01) discard;
	out_frag_color = color;
}
