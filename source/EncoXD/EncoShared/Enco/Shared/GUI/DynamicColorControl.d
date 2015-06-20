module Enco.Shared.GUI.DynamicColorControl;

import EncoShared;

class DynamicColorControl : Control
{
	private vec4 m_color4f;
	private Color m_color;

	public @property Color color()
	{
		return m_color;
	}
	public @property void color(Color color)
	{
		m_color = color; m_color4f = vec4(color.R * 0.00392156862f, color.G * 0.00392156862, color.B * 0.00392156862, 1);
	}

	public this(Color color = Color.White)
	{
		this.color = color;
	}

	override protected void drawGUI(GUIRenderer renderer)
	{
		renderer.renderRectangle(vec2(x, y), vec2(width, height), renderer.white, m_color4f);
	}
}
