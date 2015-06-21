module Enco.Shared.GUI.SpriteControl;

import EncoShared;

class SpriteControl : Control
{
	private ITexture m_texture;
	private vec4 m_color4f;
	private vec4 m_clip;
	private Color m_color;

	public @property Color color()
	{
		return m_color;
	}

	public @property void color(Color color)
	{
		m_color = color; m_color4f = vec4(color.R * 0.00392156862f, color.G * 0.00392156862, color.B * 0.00392156862, 1);
	}

	public @property ref f32 opacity()
	{
		return m_color4f.w;
	}

	public @property ref vec4 clip()
	{
		return m_clip;
	}

	public @property void texture(ITexture texture)
	{
		m_texture = texture;
	}

	public @property ITexture texture()
	{
		return m_texture;
	}

	public this(ITexture texture = null)
	{
		m_texture = texture;
		m_clip = vec4(0, 0, 1, 1);
		color = Color.White;
	}

	public static PictureControl fromColor(T : ITexture)(Color color)
	{
		ITexture tex = new T();
		tex.create(1, 1, cast(ubyte[])[color.R, color.G, color.B, 255]);
		return new PictureControl(tex);
	}

	override protected void drawGUI(GUIRenderer renderer)
	{
		if(m_texture !is null)
			renderer.renderRectangle(vec2(x, y), vec2(width, height), m_clip, m_texture, m_color4f);
	}
}
