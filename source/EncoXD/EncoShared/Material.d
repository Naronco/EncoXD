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
		program.set("l_direction", context.lightDirection);
		program.bind();
	}
}