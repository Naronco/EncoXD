#version 330

out vec4 out_frag_color;

const vec3 ambient = vec3(0.0235, 0.039, 0.049);

uniform sampler2D texSlot0;
uniform float texScale;

in vec2 texCoord;
in vec3 normal;

void main()
{
	vec4 color = texture(texSlot0, texCoord * texScale);
	if(color.a < 0.5) discard;
	float diffuse = clamp(dot(normal, normalize(vec3(0.75, 1, 0.5))), 0, 1);
	out_frag_color = color * vec4(ambient + vec3(diffuse), 1);
}
