module Enco.Shared.GUI.PictureControl;

import EncoShared;

class PictureControl : Control
{
	private ITexture m_texture;
	private vec4 m_color4f;
	private Color m_color;

	public @property Color color() { return m_color; }
	public @property void color(Color color) { m_color = color; m_color4f = vec4(color.R * 0.00392156862f, color.G * 0.00392156862, color.B * 0.00392156862, 1); }

	public this(ITexture texture)
	{
		m_texture = texture;
		width = texture.width;
		height = texture.height;
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
		renderer.renderRectangle(vec2(x, y), vec2(width, height), m_texture, m_color4f);
	}
}
