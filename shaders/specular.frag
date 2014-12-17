#version 330

@{TextureSlots}

uniform vec3 l_direction;
uniform vec3 cam_translation;

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
	vec4 color = @{Color:vec4(1, 0, 1, 1)};
	if(color.a < 0.01) discard;
	float diffuse = dot(normal, normalize(l_direction));


	vec3 reflectionDirection = normalize(reflect(-normalize(l_direction), normal));
	vec3 viewDirection = normalize(cam_translation - eyeVec);
	float specIntensity = pow(dot(viewDirection, reflectionDirection), @{Shininess:32});
	vec3 spec = vec3(0);
	if(specIntensity > 0 && diffuse > 0) spec = vec3(specIntensity * @{Intensity:10}) * @{LightColor:vec3(1, 1, 1)};
	out_frag_color = color * vec4(@{Ambient:vec3(0.1, 0.1, 0.1)} + vec3(clamp(diffuse, 0, 1)) + spec, 1);
}
