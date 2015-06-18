module Enco.Shared.GUI.TextControl;

import EncoShared;

class TextControl(T : ITexture) : Control
{
	private ITexture m_texture;
	private string	 m_text;
	private Font	 m_font;
	private vec4	 m_color4f;
	private Color	 m_color;

	public @property Color color()
	{
		return m_color;
	}
	public @property void color(Color color)
	{
		m_color = color; m_color4f = vec4(color.R * 0.00392156862f, color.G * 0.00392156862, color.B * 0.00392156862, 1);
	}

	public @property string text()
	{
		return m_text;
	}
	public @property void text(string text)
	{
		if (text == m_text)
			return;
		m_text	  = text;
		m_texture = m_font.render!T(text, Color.White);
		width	  = m_texture.width;
		height	  = m_texture.height;
	}

	public this(Font font)
	{
		m_font = font;
		color  = Color.White;
	}

	override protected void drawGUI(GUIRenderer renderer)
	{
		renderer.renderRectangle(vec2(x, y), vec2(width, height), m_texture, m_color4f);
	}
}
