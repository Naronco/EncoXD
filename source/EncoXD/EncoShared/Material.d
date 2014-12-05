module Enco.Shared.Material;

import EncoShared;

struct Material
{
	string name;

	ITexture[int] textures;

	ShaderProgram program;

	void bind(RenderContext context)
	{
		foreach(int id, ITexture texture; textures)
		{
			texture.bind(id);
		}
		program.bind();
		program.set("l_direction", context.lightDirection);
		const auto r = context.camera.transform.rotation;
		const float crx = cos(r.x);
		const float srx = sin(r.x);
		const float cry = cos(r.y);
		const float sry = sin(r.y);
		program.set("l_viewDir", vec3(srx * cry, crx * cry, sry));
	}
}