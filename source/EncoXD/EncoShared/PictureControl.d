module Enco.Shared.GUI.PictureControl;

import EncoShared;

class PictureControl : Control
{
	private ITexture m_texture;

	public this(ITexture texture)
	{
		m_texture = texture;
	}

	public static PictureControl fromColor(T : ITexture)(Color color)
	{
		ITexture tex = new T();
		tex.create(1, 1, cast(ubyte[])[color.R, color.G, color.B, 255]);
		return new PictureControl(tex);
	}

	override protected void drawGUI(GUIRenderer renderer)
	{
		renderer.renderRectangle(vec2(x, y), vec2(width, height), m_texture);
	}
}