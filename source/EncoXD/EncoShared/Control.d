module Enco.Shared.GUI.Control;

import EncoShared;

class Control : GameObject
{
	public this()
	{
		m_x = 0;
		m_y = 0;
		m_width = 100;
		m_height = 100;
		m_parent = null;
		m_background = Color.White;
		m_foreground = Color.Black;
	}

	public void makeParent(Control child)
	{
		child.m_parent = this;
	}

	override protected void draw2D(GUIRenderer renderer)
	{
		if(parent !is null && m_x <= parent.width && m_y <= parent.height && x >= -width && y >= -height && m_visible)
			return;
		drawGUI(renderer);
	}

	protected abstract void drawGUI(GUIRenderer renderer) {}
	
	public @property f32 x() { if(m_parent !is null) return m_x + m_parent.x; return m_x; }
	public @property f32 y() { if(m_parent !is null) return m_y + m_parent.y; return m_y; }
	
	public @property void x(f32 value) { m_x = value; }
	public @property void y(f32 value) { m_y = value; }
	
	public @property ref f32 width() { return m_width; }
	public @property ref f32 height() { return m_height; }
	
	public @property ref Color background() { return m_background; }
	public @property ref Color foreground() { return m_foreground; }

	public @property ref bool visible() { return m_visible; }
	
	public @property Control parent() { return m_parent; }
	
	private f32 m_x, m_y;
	private f32 m_width, m_height;
	private bool m_visible;
	private Color m_background, m_foreground;

	private Control m_parent;
}