module Enco.Desktop.DesktopView;

import std.json;
import std.stdio;

import EncoDesktop;
import EncoShared;

abstract class DesktopView : IView
{
	public @property Window window()
	{
		return m_window;
	}
	public @property bool valid()
	{
		return m_valid;
	}

	private bool m_valid = false;
	private Window m_window;
	private bool m_closed = false;

	public Event!u32vec2 onResized = new Event!u32vec2;
	public Event!u32vec2 onMove = new Event!u32vec2;
	public Trigger onShow = new Trigger;
	public Trigger onHide = new Trigger;
	public Trigger onExpose = new Trigger;
	public Trigger onMinimize = new Trigger;
	public Trigger onMaximize = new Trigger;
	public Trigger onRestore = new Trigger;
	public Trigger onEnter = new Trigger;
	public Trigger onLeave = new Trigger;
	public Trigger onFocusGain = new Trigger;
	public Trigger onFocusLost = new Trigger;
	public Trigger onClose = new Trigger;

	public this(string title, u32vec2 size = u32vec2(320, 240)) { m_name = title; m_size = size; }
	public this(string title, uint width, uint height) { this(title, u32vec2(width, height)); }
	public this() { this("", 0, 0); }
	public ~this() {}

	public override void create()
	{
		assert(m_renderer !is null);

		auto flags = SDL_WINDOW_SHOWN;

		if (m_size.x == 0 && m_size.y == 0)
		{
			SDL_DisplayMode current;

			SDL_GetCurrentDisplayMode(0, &current);

			m_size.x = current.w;
			m_size.y = current.h;

			flags = SDL_WINDOW_BORDERLESS;
		}

		m_window = new Window(m_name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, cast(int) m_size.x, cast(int) m_size.y, flags | cast(uint) renderer.getSDLOptions());
		if (!m_window.valid)
		{
			throw new Exception("Window failed");
		}

		m_renderer.createContext(0, 0, m_size.x, m_size.y, 32, 16, 0, false, m_window);
		m_valid = true;
	}

	public override void importSettings(JSONValue json)
	{
		try
		{
			if (("Window" in json) !is null && json["Window"].type == JSON_TYPE.OBJECT)
			{
				if (("Width" in json["Window"]) !is null && ("Height" in json["Window"]) !is null && json["Window"]["Width"].type == JSON_TYPE.INTEGER && json["Window"]["Height"].type == JSON_TYPE.INTEGER)
				{
					size = u32vec2(cast(uint) json["Window"]["Width"].integer, cast(uint) json["Window"]["Height"].integer);
				}
				if (("Title" in json["Window"]) !is null && json["Window"]["Title"].type == JSON_TYPE.STRING)
				{
					name = json["Window"]["Title"].str;
				}
			}
		}
		catch (Exception e)
		{
			Logger.errln(e);
		}
	}

	public override void destroy()
	{
		if (valid)
		{
			m_renderer.deleteContext();

			if (m_window !is null && m_window.valid)
			{
				m_window.destroy();
				m_window = null;
			}

			if (m_scene !is null)
			{
				m_scene.destroy();
				m_scene = null;
			}
		}
	}

	public override void handleEvent(ref SDL_Event event)
	{
		if (valid && !m_closed)
		{
			if (event.type == SDL_WINDOWEVENT && event.window.windowID == window.id)
			{
				switch (event.window.event)
				{
				case SDL_WINDOWEVENT_SHOWN:
					onShow(this);
					break;
				case SDL_WINDOWEVENT_HIDDEN:
					onHide(this);
					break;
				case SDL_WINDOWEVENT_EXPOSED:
					onExpose(this);
					break;
				case SDL_WINDOWEVENT_MOVED:
					onMove(this, u32vec2(event.window.data1, event.window.data2));
					break;
				case SDL_WINDOWEVENT_RESIZED:
					size = u32vec2(event.window.data1, event.window.data2);
					onResized(this, size);
					break;
				case SDL_WINDOWEVENT_MINIMIZED:
					onMinimize(this);
					break;
				case SDL_WINDOWEVENT_MAXIMIZED:
					onMaximize(this);
					break;
				case SDL_WINDOWEVENT_RESTORED:
					onRestore(this);
					break;
				case SDL_WINDOWEVENT_ENTER:
					onEnter(this);
					break;
				case SDL_WINDOWEVENT_LEAVE:
					onLeave(this);
					break;
				case SDL_WINDOWEVENT_FOCUS_GAINED:
					onFocusGain(this);
					break;
				case SDL_WINDOWEVENT_FOCUS_LOST:
					onFocusLost(this);
					break;
				case SDL_WINDOWEVENT_CLOSE:
					onClose(this);
					EncoContext.instance.removeView(this);
					m_closed = true;
					window.hide();
					break;
				default: break;
				}
			}
		}
	}

	protected override void onResize()
	{
		if (valid)
		{
			m_window.size = m_size;
		}
	}

	protected override void onRename()
	{
		if (valid)
		{
			m_window.title = m_name;
		}
	}
}
