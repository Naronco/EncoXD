module Enco.Shared.GUI.Control;

import EncoShared;

enum Alignment
{
	Top          = 1 << 0,
	Bottom       = 1 << 1,
	Left         = 1 << 2,
	Right        = 1 << 3,

	TopLeft      = Top | Left,
	TopRight     = Top | Right,
	TopCenter    = Top | Left | Right,
	MiddleLeft   = Bottom | Top | Left,
	MiddleRight  = Bottom | Top | Right,
	MiddleCenter = Bottom | Top | Left | Right,
	BottomLeft   = Bottom | Left,
	BottomRight  = Bottom | Right,
	BottomCenter = Bottom | Left | Right,
}

public int getHorizontal(Alignment alignment)
{
	if ((alignment & Alignment.Left) == Alignment.Left && (alignment & Alignment.Right) != Alignment.Right)
		return -1;
	if ((alignment & Alignment.Left) != Alignment.Left && (alignment & Alignment.Right) == Alignment.Right)
		return 1;
	if ((alignment & Alignment.Left) == Alignment.Left && (alignment & Alignment.Right) == Alignment.Right)
		return 0;
	return -1;
}

unittest
{
	assert(Alignment.TopLeft.getHorizontal() == -1);
	assert(Alignment.MiddleCenter.getHorizontal() == 0);
	assert(Alignment.BottomRight.getHorizontal() == 1);
	assert(Alignment.Top.getHorizontal() == -1);
}

public int getVertical(Alignment alignment)
{
	if ((alignment & Alignment.Top) == Alignment.Top && (alignment & Alignment.Bottom) != Alignment.Bottom)
		return -1;
	if ((alignment & Alignment.Top) != Alignment.Top && (alignment & Alignment.Bottom) == Alignment.Bottom)
		return 1;
	if ((alignment & Alignment.Top) == Alignment.Top && (alignment & Alignment.Bottom) == Alignment.Bottom)
		return 0;
	return -1;
}

unittest
{
	assert(Alignment.TopLeft.getVertical() == -1);
	assert(Alignment.MiddleCenter.getVertical() == 0);
	assert(Alignment.BottomRight.getVertical() == 1);
	assert(Alignment.Left.getVertical() == -1);
}

class Control : GameObject
{
	public this()
	{
		m_x = 0;
		m_y = 0;
		m_width = 100;
		m_height = 100;
		m_background = Color.White;
		m_foreground = Color.Black;
		m_align = Alignment.TopLeft;
	}

	override protected void draw2D(GUIRenderer renderer)
	{
		if (!m_visible)
			return;
		m_guiSize.x = renderer.size.x;
		m_guiSize.y = renderer.size.y;
		drawGUI(renderer);
	}

	protected abstract void drawGUI(GUIRenderer renderer)
	{
	}

	private f32 computeX(f32 x, f32 parentWidth)
	{
		if (m_align.getHorizontal() == -1)
			return x;
		else if (m_align.getHorizontal() == 1)
			return parentWidth - x - width;
		else
			return (cast(i32) (parentWidth - width) >> 1) + x;
	}

	private f32 computeY(f32 y, f32 parentHeight)
	{
		if (m_align.getVertical() == -1)
			return y;
		else if (m_align.getVertical() == 1)
			return parentHeight - y - height;
		else
			return (cast(i32) (parentHeight - height) >> 1) + y;
	}

	public void size(f32 x, f32 y, f32 width, f32 height)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public @property f32 x()
	{
		if (cast(Control) parent)
			return computeX(m_x, (cast(Control) parent).width) + (cast(Control) parent).x;
		return computeX(m_x, m_guiSize.x);
	}

	public @property f32 y()
	{
		if (cast(Control) parent)
			return computeY(m_y, (cast(Control) parent).height) + (cast(Control) parent).y;
		return computeY(m_y, m_guiSize.y);
	}

	public @property void x(f32 value)
	{
		m_x = value;
	}
	public @property void y(f32 value)
	{
		m_y = value;
	}

	public @property ref f32 width()
	{
		return m_width;
	}
	public @property ref f32 height()
	{
		return m_height;
	}

	public @property ref Color background()
	{
		return m_background;
	}
	public @property ref Color foreground()
	{
		return m_foreground;
	}

	public @property ref bool visible()
	{
		return m_visible;
	}
	public @property ref Alignment alignment()
	{
		return m_align;
	}

	private f32 m_x, m_y;
	private f32 m_width, m_height;
	private bool m_visible = true;
	private Color m_background, m_foreground;
	private vec2 m_guiSize;
	private Alignment m_align;
}
