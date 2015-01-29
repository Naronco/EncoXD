module Enco.Shared.Render.GUIRenderer;

import std.json;

import EncoShared;

class GUIRenderer
{
	private IRenderer renderer;
	private Mesh quad;
	private Material material;
	private bool depthTestState = false;
	private bool blendState = false;

	private float iwidth, iheight;

	public this(IRenderer renderer, Material material)
	{
		this.renderer = renderer;

		quad = renderer.createMesh(MeshUtils.createPlane(0, 1, 1, 0, 0, 1, 1, 0));

		this.material = material;

		iwidth = 1.0f;
		iheight = 1.0f;

		material.program.registerUniforms(["slot0", "color"]);
		material.program.set("slot0", 0);
		material.program.set("color", vec4(1, 1, 1, 1));
	}

	public void resize(u32 width, u32 height)
	{
		iwidth = 1.0f / width;
		iheight = 1.0f / height;
	}

	public void begin()
	{
		depthTestState = renderer.enableDepthTest;
		blendState = renderer.enableBlend;
		renderer.enableDepthTest = false;
		renderer.enableBlend = true;
	}

	public void end()
	{
		renderer.enableDepthTest = depthTestState;
		renderer.enableBlend = blendState;
	}

	public void renderRectangle(vec2 position, vec2 size, ITexture texture, vec4 color = vec4(1, 1, 1, 1))
	{
		material.program.bind();

		material.program.set("color", color);
		material.program.set("modelview", mat4.identity.translate(position.x * iwidth * 2 - 1, -(position.y * iheight * 2 + size.y * iheight * 2 - 1), 0) * mat4.identity.scale(size.x * iwidth * 2, size.y * iheight * 2, 1));
		material.program.set("projection", mat4.identity);

		texture.bind(0);

		renderer.renderMesh(quad);
	}
}