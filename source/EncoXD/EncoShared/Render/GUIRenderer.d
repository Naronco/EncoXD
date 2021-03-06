module EncoShared.Render.GUIRenderer;

import std.json;

import EncoShared;

class GUIRenderer
{
	private IRenderer renderer;
	private Mesh quad;
	private Material material;
	private bool depthTestState = false;

	private float iwidth, iheight;
	private vec2 m_size;

	public this(IRenderer renderer, Material material)
	{
		this.renderer = renderer;

		quad = renderer.createMesh(MeshUtils.createPlane(0, 1, 1, 0, 0, 1, 1, 0));

		this.material = material;

		iwidth = 1.0f;
		iheight = 1.0f;
		m_size = vec2(1, 1);

		material.program.registerUniforms(["slot0", "color", "clip"]);
		material.program.set("slot0", 0);
		material.program.set("color", vec4(1, 1, 1, 1));
		material.program.set("clip", vec4(0, 0, 1, 1));
	}

	public @property vec2 size()
	{
		return m_size;
	}

	public void resize(uint width, uint height)
	{
		iwidth = 1.0f / width;
		iheight = 1.0f / height;
		m_size = vec2(width, height);
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

	public void renderMesh(Mesh mesh, vec2 position, vec2 size, ITexture texture, vec4 color = vec4(1, 1, 1, 1))
	{
		material.bind(renderer);

		material.program.set("clip", vec4(0, 0, 1, 1));
		material.program.set("color", color);
		material.program.set("modelview", mat4.identity.translate(position.x * iwidth * 2 - 1, -(position.y * iheight * 2 + size.y * iheight * 2 - 1), 0) * mat4.identity.scale(size.x * iwidth * 2, size.y * iheight * 2, 1));
		material.program.set("projection", mat4.identity);

		texture.bind(0);

		renderer.renderMesh(mesh);
	}

	public void renderRectangle(vec2 position, vec2 size, ITexture texture, vec4 color = vec4(1, 1, 1, 1))
	{
		material.bind(renderer);

		material.program.set("clip", vec4(0, 0, 1, 1));
		material.program.set("color", color);
		material.program.set("modelview", mat4.identity.translate(position.x * iwidth * 2 - 1, -(position.y * iheight * 2 + size.y * iheight * 2 - 1), 0) * mat4.identity.scale(size.x * iwidth * 2, size.y * iheight * 2, 1));
		material.program.set("projection", mat4.identity);

		texture.bind(0);

		renderer.renderMesh(quad);
	}

	public void renderRectangle(vec2 position, vec2 size, vec4 clip, ITexture texture, vec4 color = vec4(1, 1, 1, 1))
	{
		material.bind(renderer);

		material.program.set("clip", vec4(clip.x / cast(float) texture.width, clip.y / cast(float) texture.height, clip.z / cast(float) texture.width, clip.w / cast(float) texture.height));
		material.program.set("color", color);
		material.program.set("modelview", mat4.identity.translate(position.x * iwidth * 2 - 1, -(position.y * iheight * 2 + size.y * iheight * 2 - 1), 0) * mat4.identity.scale(size.x * iwidth * 2, size.y * iheight * 2, 1));
		material.program.set("projection", mat4.identity);

		texture.bind(0);

		renderer.renderMesh(quad);
	}

	public @property ITexture white()
	{
		return renderer.white;
	}
}
