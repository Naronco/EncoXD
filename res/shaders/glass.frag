#version 330

@{TextureSlots}

uniform vec3 l_direction;

const vec3 ambient = @{Ambient};

in vec3 normal;

layout(location = 0) out vec4 out_frag_color;

void main()
{
	vec4 color = vec4(1);
	if(color.a < 0.01) discard;
	float diffuse = clamp(dot(normal, normalize(l_direction)), 0, 1);
	out_frag_color = color * vec4(ambient + vec3(diffuse), 1);
}
