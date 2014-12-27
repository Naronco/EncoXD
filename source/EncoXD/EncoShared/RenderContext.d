module Enco.Shared.RenderContext;

import EncoShared;

struct RenderContext
{
	this(Camera camera, vec3 l_dir = vec3(1, 1, 1))
	{
		this.camera = camera;
		lightDirection = l_dir;
	}

	Camera camera;
	vec3 lightDirection = vec3(1, 1, 1);
}