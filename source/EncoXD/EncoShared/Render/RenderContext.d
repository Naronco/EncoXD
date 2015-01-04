module Enco.Shared.Render.RenderContext;

import EncoShared;

struct RenderContext
{
	public this(Camera camera, vec3 l_dir = vec3(1, 1, 1))
	{
		this.camera = camera;
		lightDirection = l_dir;
	}

	public Camera camera;
	public vec3 lightDirection = vec3(1, 1, 1);
}