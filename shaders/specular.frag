#version 330

@{TextureSlots}

uniform vec3 l_direction;
uniform vec3 transl;

const vec3 ambient = @{Ambient};

in vec3 normal;
in vec2 texCoord;
in vec3 eyeVec;

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
	vec4 color = @{Color};
	if(color.a < 0.01) discard;
	float diffuse = clamp(dot(normal, normalize(l_direction)), 0, 1);


	vec3 reflectionDirection = normalize(reflect(-normalize(l_direction), normal));
	vec3 viewDirection = normalize(transl - eyeVec);
	float specIntensity = pow(dot(viewDirection, reflectionDirection), 32);
	float spec = 0;
	if(specIntensity > 0) spec = specIntensity * 10;
	out_frag_color = color * vec4(ambient + vec3(diffuse) + vec3(spec), 1);
}
