#version 330

uniform sampler2D slot0;
uniform sampler3D slot1;
uniform sampler2D slot2;

in vec2 texCoord;

out vec4 out_frag_color;

vec3 addFog(vec3 color)
{
	float depth = texture(slot2, texCoord).r;
	float f = clamp(pow(depth, 1000), 0, 1);
	return color * (1 - f) + vec3(0.5294117647, 0.80784313725, 0.92156862745) * f;
}

void main()
{
	float depth = texture(slot2, texCoord).r;
	float f = pow(depth * 1.5 - 0.5, 512);
	vec3 color = texture(slot0, texCoord).rgb;
	color = addFog(color);
	out_frag_color = vec4(texture(slot1, color).rgb, 1);
}
