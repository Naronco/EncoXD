module Enco.Shared.Render.Material;

import EncoShared;

struct Material
{
	public string name;

	public ITexture[int] textures;

	public ShaderProgram program;

	public void bind(RenderContext context)
	{
		foreach(int id, ITexture texture; textures)
		{
			texture.bind(id);
		}
		program.bind();
		program.set("l_direction", context.lightDirection);
		program.set("cam_translation", context.camera.transform.position);
	}
}