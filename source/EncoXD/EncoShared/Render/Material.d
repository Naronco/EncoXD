module Enco.Shared.Render.Material;

import EncoShared;

struct Material
{
	public string name;
	
	public bool blend = false;
	public bool depth = true;

	public ITexture[int] textures;

	public ShaderProgram program;

	public void bind(IRenderer renderer, RenderContext context)
	{
		foreach(int id, ITexture texture; textures)
		{
			texture.bind(id);
		}
		program.bind();
		program.set("l_direction", context.lightDirection);
		program.set("cam_translation", context.camera.transform.position);
		renderer.enableBlend = blend;
		renderer.enableDepthTest = depth;
	}

	public void bind(IRenderer renderer)
	{
		foreach(int id, ITexture texture; textures)
		{
			texture.bind(id);
		}
		program.bind();
		renderer.enableBlend = blend;
		renderer.enableDepthTest = depth;
	}
}