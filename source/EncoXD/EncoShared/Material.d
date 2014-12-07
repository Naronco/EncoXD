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
		program.set("transl", context.camera.transform.position);
	}
}