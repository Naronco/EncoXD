#version 330

uniform sampler2D slot0;
uniform sampler2D slot1;
uniform sampler2D slot2;
uniform sampler2D slot3;

uniform float dist;
uniform float time;
uniform float fade;

in vec2 texCoord;

out vec4 out_frag_color;

vec3 addFog(vec3 color)
{
	float depth = texture(slot1, texCoord).r;
	if(depth == 1)
		return color;
	float f = clamp(pow(depth, texture(slot3, vec2(time, 0)).r * 4000) * dist, 0, 1);
	return color * (1 - f) + texture(slot2, vec2(time, 0.95)).rgb * f;
}

void main()
{
	float depth = texture(slot1, texCoord).r;
	float f = pow(depth * 1.5 - 0.5, 512);
	vec3 color = texture(slot0, texCoord).rgb;
	color = addFog(color);
	out_frag_color = vec4(color * fade, 1);
}
