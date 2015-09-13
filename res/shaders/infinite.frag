#version 330

@{TextureSlots}

uniform sampler2D permTexture;

uniform vec3 l_direction;
uniform float time;

in vec3 normal;
in vec2 texCoord;

layout(location = 0) out vec4 out_frag_color;

/*
 * To create offsets of one texel and one half texel in the
 * texture lookup, we need to know the texture image size.
 */
#define ONE 0.00390625
#define ONEHALF 0.001953125
// The numbers above are 1/256 and 0.5/256, change accordingly
// if you change the code to use another texture size.


/*
 * The interpolation function. This could be a 1D texture lookup
 * to get some more speed, but it's not the main part of the algorithm.
 */
float fade(float t) {
  // return t*t*(3.0-2.0*t); // Old fade, yields discontinuous second derivative
  return t*t*t*(t*(t*6.0-15.0)+10.0); // Improved fade, yields C2-continuous noise
}

/*
 * 2D classic Perlin noise. Fast, but less useful than 3D noise.
 */
float noise(vec2 P)
{
  vec2 Pi = ONE*floor(P)+ONEHALF; // Integer part, scaled and offset for texture lookup
  vec2 Pf = fract(P);             // Fractional part for interpolation

  // Noise contribution from lower left corner
  vec2 grad00 = texture2D(permTexture, Pi).rg * 4.0 - 1.0;
  float n00 = dot(grad00, Pf);

  // Noise contribution from lower right corner
  vec2 grad10 = texture2D(permTexture, Pi + vec2(ONE, 0.0)).rg * 4.0 - 1.0;
  float n10 = dot(grad10, Pf - vec2(1.0, 0.0));

  // Noise contribution from upper left corner
  vec2 grad01 = texture2D(permTexture, Pi + vec2(0.0, ONE)).rg * 4.0 - 1.0;
  float n01 = dot(grad01, Pf - vec2(0.0, 1.0));

  // Noise contribution from upper right corner
  vec2 grad11 = texture2D(permTexture, Pi + vec2(ONE, ONE)).rg * 4.0 - 1.0;
  float n11 = dot(grad11, Pf - vec2(1.0, 1.0));

  // Blend contributions along x
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade(Pf.x));

  // Blend contributions along y
  float n_xy = mix(n_x.x, n_x.y, fade(Pf.y));

  // We're done, return the final noise value.
  return n_xy;
}

void main()
{
	vec4 color = texture(slot1, texCoord * vec2(60, 30) - vec2(0, time)) * vec4(1, 0.9, 0.85, 1);
	if(texCoord.x > 0.494 && texCoord.x < 0.506)
	{
		float ni = pow(noise(texCoord * vec2(60, 30) - vec2(0, time)), 2);
		color = color * ni + texture(slot0, texCoord * vec2(60, 30) - vec2(0, time)) * (1 - ni);
	}
	if(texCoord.x > 0.4945 && texCoord.x < 0.495 || texCoord.x > 0.505 && texCoord.x < 0.5055)
		color *= 2; // White side strips

	if(texCoord.x > 0.49985 && texCoord.x < 0.50015 && mod(floor(texCoord.y * 45 - time * 1.5), 2) < 1)
		color *= 2; // White strips

	float diffuseIntensity = clamp(dot(normal, normalize(l_direction)), 0, 1);
	vec4 diffuse = clamp(vec4(vec3(0.1, 0.1, 0.1) + vec3(diffuseIntensity), 1), 0, 1);
	out_frag_color = color * diffuse;
}
