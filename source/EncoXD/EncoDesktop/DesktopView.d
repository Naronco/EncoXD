module Enco.Desktop.DesktopView;

import std.json;
import std.stdio;

import EncoDesktop;
import EncoShared;

struct KeyboardState
{
	public bool[int] keys;
	
	public bool isKeyDown(u32 key)
	{
		return (key in keys) !is null;
	}

	public bool isKeyUp(u32 key)
	{
		return (key in keys) is null;
	}
}

class Keyboard
{
	public static KeyboardState* getState() { return new KeyboardState(keys.dup); }

	private static void setKey(u32 key, bool state)
	{
		if(state)
			keys[key] = true;
		else
			keys.remove(key);
	}

	private static bool[int] keys;
}

struct MouseState
{
	public vec2 position;
	public vec2 offset;
	public bool[] buttons = new bool[8];
	
	public bool isButtonDown(u8 button)
	{
		return buttons[button];
	}

	public bool isButtonUp(u8 button)
	{
		return !buttons[button];
	}
}

class Mouse
{
	public static MouseState* getState()
	{
		MouseState* state = new MouseState();
		state.position = position;
		state.offset = offset;
		state.buttons[] = buttons;
		return state;
	}
	
	public static void capture(DesktopView window)
	{
		SDL_SetRelativeMouseMode(true);
		SDL_ShowCursor(false);
		SDL_SetWindowGrab(window.handle, true);
	}
	
	public static void release(DesktopView window)
	{
		SDL_SetRelativeMouseMode(false);
		SDL_ShowCursor(true);
		SDL_SetWindowGrab(window.handle, false);
	}

	private static void setButton(i8 button, bool isDown)
	{
		buttons[button - 1] = isDown;
	}

	private static void setPosition(i32 x, i32 y)
	{
		position.x = x;
		position.y = y;
	}

	private static void addOffset(i32 x, i32 y)
	{
		offset.x += x;
		offset.y += y;
	}

	private static void setOffset(i32 x, i32 y)
	{
		offset.x = x;
		offset.y = y;
	}
	
	private static vec2 position = vec2(0, 0);
	private static vec2 offset = vec2(0, 0);
	private static bool[] buttons = new bool[8];
}

class DesktopView : IView
{
	public this(string title, u32vec2 size = u32vec2(320, 240)) { m_name = title; m_size = size; }
	public this(string title, u32 width, u32 height) { this(title, u32vec2(width, height)); }
	public this() { this("", 0, 0); }
	public ~this() {}

	public override void create(IRenderer renderer)
	{
		assert(renderer !is null);

		m_renderer = renderer;
		
		SDL_Init(SDL_INIT_VIDEO);

		auto flags = SDL_WINDOW_SHOWN;

		if(m_size.x == 0 && m_size.y == 0)
		{
			SDL_DisplayMode current;

			SDL_GetCurrentDisplayMode(0, &current);
			
			m_size.x = current.w;
			m_size.y = current.h;

			flags = SDL_WINDOW_BORDERLESS;
		}

		m_window = SDL_CreateWindow(m_name.ptr, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, cast(int)m_size.x, cast(int)m_size.y, flags | cast(uint)renderer.getSDLOptions());
		if(!m_window)
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
			if(("Window" in json) !is null && json["Window"].type == JSON_TYPE.OBJECT)
			{
				if(("Width" in json["Window"]) !is null && ("Height" in json["Window"]) !is null && json["Window"]["Width"].type == JSON_TYPE.INTEGER && json["Window"]["Height"].type == JSON_TYPE.INTEGER)
				{
					size = u32vec2(cast(u32)json["Window"]["Width"].integer, cast(u32)json["Window"]["Height"].integer);
				}
				if(("Title" in json["Window"]) !is null && json["Window"]["Title"].type == JSON_TYPE.STRING)
				{
					name = json["Window"]["Title"].str ~ "\0";
				}
			}
		}
		catch(Exception e)
		{
			Logger.errln(e);
		}
	}

	public override void destroy()
	{
		if(valid)
		{
			m_renderer.deleteContext();

			if(m_window)
			{
				SDL_DestroyWindow(m_window);
				m_window = null;
			}

			SDL_Quit();
		}
	}

	public override bool update(f64 deltaTime)
	{
		if(valid)
		{
			Mouse.setOffset(0, 0);
			SDL_Event event;
			while (SDL_PollEvent(&event)) {
				switch (event.type) {
				case SDL_QUIT:
					return false;
				case SDL_KEYDOWN:
					Keyboard.setKey(event.key.keysym.sym, true);
					break;
				case SDL_KEYUP:
					Keyboard.setKey(event.key.keysym.sym, false);
					break;
				case SDL_MOUSEMOTION:
					Mouse.setPosition(event.motion.x, event.motion.y);
					Mouse.addOffset(event.motion.xrel, event.motion.yrel);
					break;
				case SDL_MOUSEBUTTONDOWN:
				case SDL_MOUSEBUTTONUP:
					Mouse.setPosition(event.button.x, event.button.y);
					Mouse.setButton(event.button.button, event.button.state == SDL_PRESSED);
					break;
				default: break;
				}
			}
			return true;
		}
		return false;
	}
	
	protected override void onResize()
	{
		if(valid)
		{
			SDL_SetWindowSize(m_window, cast(int)m_size.x, cast(int)m_size.y);
		}
	}

	protected override void onRename()
	{
		if(valid)
		{
			SDL_SetWindowTitle(m_window, m_name.ptr);
		}
	}

	public @property SDL_Window* handle() { return m_window; }
	public @property bool valid() { return m_valid; }

	private bool m_valid = false;
	private SDL_Window* m_window;
	private IRenderer m_renderer;
}