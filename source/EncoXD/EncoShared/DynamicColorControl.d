module Enco.Shared.GUI.DynamicColorControl;

import EncoShared;

class DynamicColorControl : Control
{
	private ITexture m_white;
	private vec4 m_color4f;
	private Color m_color;

	public @property Color color() { return m_color; }
	public @property void color(Color color) { m_color = color; m_color4f = vec4(color.R * 0.00392156862f, color.G * 0.00392156862, color.B * 0.00392156862, 1); }

	private this(ITexture white, Color color)
	{
		m_white = white;
		this.color = color;
	}

	public static DynamicColorControl create(T : ITexture)(Color color)
	{
		ITexture tex = new T();
		tex.create(1, 1, cast(ubyte[])[255, 255, 255, 255]);
		return new DynamicColorControl(tex, color);
	}

	override protected void drawGUI(GUIRenderer renderer)
	{
		renderer.renderRectangle(vec2(x, y), vec2(width, height), m_white, m_color4f);
	}
}