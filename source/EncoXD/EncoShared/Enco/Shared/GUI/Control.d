module Enco.Shared.GUI.Control;

import EncoShared;

enum Alignment : byte
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

version(DisableGUILength)
{
	alias GUILength = f32;
}
else
{
	version = UseGUILength;
}

version(UseGUILength)
{
	import std.traits;
	import std.conv;

	enum GUILengthUnit : byte
	{
		Pixel,
		Percentage,
		ViewportWidth,
		ViewportHeight
	}

	struct GUILength
	{
		f32 amount;
		GUILengthUnit unit;

		this(T)(T amount_, GUILengthUnit unit_ = GUILengthUnit.Pixel) if(isNumeric!T)
		{
			amount = cast(f32)amount_;
			unit = unit_;
		}

		f32 computePixels(f32 vw, f32 vh, f32 parentLength)
		{
			if(unit == GUILengthUnit.Pixel) return amount;
			else if(unit == GUILengthUnit.Percentage) return amount * 0.01 * parentLength;
			else if(unit == GUILengthUnit.ViewportWidth) return amount * 0.01 * vw;
			else if(unit == GUILengthUnit.ViewportHeight) return amount * 0.01 * vh;
			else throw new Exception("Undefined GUI Length Unit!");
		}

		void opAssign(T)(T newAmount) if(isNumeric!T)
		{
			amount = cast(f32)newAmount;
			unit = GUILengthUnit.Pixel;
		}

		T opCast(T)() if(is(T == f32))
		{
			return amount;
		}

		string toString()
		{
			if(unit == GUILengthUnit.Pixel) return to!string(amount) ~ "px";
			else if(unit == GUILengthUnit.Percentage) return to!string(amount) ~ "%";
			else if(unit == GUILengthUnit.ViewportWidth) return to!string(amount) ~ "vw";
			else if(unit == GUILengthUnit.ViewportHeight) return to!string(amount) ~ "vh";
			else throw new Exception("Undefined GUI Length Unit!");
		}
	}

	GUILength px(T)(T amount) if(isNumeric!T)
	{
		return GUILength(cast(f32)amount, GUILengthUnit.Pixel);
	}

	GUILength per100(T)(T amount) if(isNumeric!T)
	{
		return GUILength(cast(f32)amount, GUILengthUnit.Percentage);
	}

	GUILength vw(T)(T amount) if(isNumeric!T)
	{
		return GUILength(cast(f32)amount, GUILengthUnit.ViewportWidth);
	}

	GUILength vh(T)(T amount) if(isNumeric!T)
	{
		return GUILength(cast(f32)amount, GUILengthUnit.ViewportHeight);
	}

	unittest
	{
		assert(100.px().computePixels(0, 0, 0) - 100 < 0.001f);
		assert(40.per100().computePixels(0, 0, 50) - 20 < 0.001f);
		assert(30.vw().computePixels(40, 0, 0) - 12 < 0.001f);
		assert(80.vh().computePixels(0, 30, 0) - 24 < 0.001f);
	}
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
		m_guiSize = vec2(0, 0);
	}

	override protected void draw2D(GUIRenderer renderer)
	{
		if (!m_visible)
			return;
		m_guiSize.x = renderer.size.x;
		m_guiSize.y = renderer.size.y;

		m_mouseState = Mouse.getState();
		m_hover = m_mouseState.position.inRect(vec4(x, y, width, height));

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

	public void size(X, Y, W, H)(X x, Y y, W width, H height)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public @property f32 x()
	{
		version(UseGUILength)
		{
			if (cast(Control) parent)
				return computeX(m_x.computePixels(m_guiSize.x, m_guiSize.y, parentWidth), parentWidth) + (cast(Control)parent).x;
			return computeX(m_x.computePixels(m_guiSize.x, m_guiSize.y, parentWidth), parentWidth);
		}
		else
			return computeX(m_x, parentWidth);
	}

	public @property f32 y()
	{
		version(UseGUILength)
		{
			if (cast(Control) parent)
				return computeY(m_y.computePixels(m_guiSize.x, m_guiSize.y, parentHeight), parentHeight) + (cast(Control)parent).y;
			return computeY(m_y.computePixels(m_guiSize.x, m_guiSize.y, parentHeight), parentHeight);
		}
		else
			return computeY(m_y, parentHeight);
	}

	version(UseGUILength)
	{
		public @property void x(f32 value)
		{
			m_x = value;
		}
		public @property void y(f32 value)
		{
			m_y = value;
		}
	}

	public @property void x(GUILength value)
	{
		m_x = value;
	}
	public @property void y(GUILength value)
	{
		m_y = value;
	}

	public @property f32 parentWidth()
	{
		if (cast(Control) parent)
			return (cast(Control)parent).width;
		return m_guiSize.x;
	}

	public @property f32 parentHeight()
	{
		if (cast(Control) parent)
			return (cast(Control)parent).height;
		return m_guiSize.y;
	}

	version(UseGUILength)
	{
		public @property void width(f32 value)
		{
			m_width = value;
		}
		public @property void height(f32 value)
		{
			m_height = value;
		}
	}

	public @property f32 width()
	{
		version(UseGUILength)
			return m_width.computePixels(m_guiSize.x, m_guiSize.y, parentWidth);
		else
			return m_width;
	}

	public @property width(GUILength value)
	{
		m_width = value;
	}


	public @property f32 height()
	{
		version(UseGUILength)
			return m_height.computePixels(m_guiSize.x, m_guiSize.y, parentHeight);
		else
			return m_height;
	}

	public @property height(GUILength value)
	{
		m_height = value;
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

	public @property bool isHover()
	{
		return m_hover;
	}

	private MouseState* m_mouseState;
	private bool m_hover;
	private GUILength m_x, m_y;
	private GUILength m_width, m_height;
	private bool m_visible = true;
	private Color m_background, m_foreground;
	private vec2 m_guiSize;
	private Alignment m_align;
}

unittest
{
	class ControlImpl : Control
	{
		protected override void drawGUI(GUIRenderer renderer)
		{
		}
	}

	ControlImpl a, b;
	a = new ControlImpl();
	b = new ControlImpl();

	a.size(0, 0, 10, 10);
	b.size(50, 50, 100, 100);

	b.addChild(a);

	a.alignment = Alignment.TopLeft;

	assert(a.x - 50 < 0.1f);
	assert(a.y - 50 < 0.1f);

	a.alignment = Alignment.MiddleCenter;

	assert(a.x - 95 < 0.1f);
	assert(a.y - 95 < 0.1f);

	a.alignment = Alignment.BottomRight;

	assert(a.x - 140 < 0.1f);
	assert(a.y - 140 < 0.1f);
}