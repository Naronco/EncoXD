#version 330

@{TextureSlots}

uniform vec3 l_direction;
uniform float time;

in vec3 normal;
in vec2 texCoord;

layout(location = 0) out vec4 out_frag_color;

void main()
{
	vec4 color = texture(slot1, texCoord * vec2(120, 60) - vec2(0, time)) * vec4(1, 0.7, 0.6, 1);
	if(texCoord.x > 0.494 && texCoord.x < 0.506)
		color = texture(slot0, texCoord * vec2(120, 60) - vec2(0, time));
	else if(texCoord.x > 0.4935 && texCoord.x < 0.5065)
		color = (color + texture(slot0, texCoord * vec2(120, 60) - vec2(0, time))) * 0.5;

	if(texCoord.x > 0.4996 && texCoord.x < 0.5004 && mod(floor(texCoord.y * 90 - time * 1.5), 2) < 1)
		color *= 2;
	float diffuseIntensity = clamp(dot(normal, normalize(l_direction)), 0, 1);
	vec4 diffuse = clamp(vec4(vec3(0.1, 0.1, 0.1) + vec3(diffuseIntensity), 1), 0, 1);
	out_frag_color = color * diffuse;
}
