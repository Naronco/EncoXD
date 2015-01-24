module Enco.Shared.Render.GUIRenderer;

import std.json;

import EncoShared;

class GUIRenderer
{
	private IRenderer renderer;
	private Mesh quad;
	private Material material;
	private bool depthTestState = false;

	private float iwidth, iheight;

	public this(IRenderer renderer, Material material, u32 width, u32 height)
	{
		this.renderer = renderer;

		quad = renderer.createMesh(MeshUtils.createPlane(0, 1, 1, 0, 0, 1, 1, 0));

		this.material = material;

		iwidth = 1.0f / width;
		iheight = 1.0f / height;

		material.program.registerUniforms(["slot0", "color"]);
		material.program.set("slot0", 0);
		material.program.set("color", vec4(1, 1, 1, 1));
	}

	public void begin()
	{
		depthTestState = renderer.enableDepthTest;
		renderer.enableDepthTest = false;
	}

	public void end()
	{
		renderer.enableDepthTest = depthTestState;
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