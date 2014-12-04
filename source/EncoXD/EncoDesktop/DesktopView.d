module Enco.Desktop.DesktopView;

import EncoDesktop;
import std.stdio;
import EncoShared;

struct KeyboardState
{
	bool[] keys = new bool[65536];
	
	bool isKeyDown(u16 key)
	{
		return keys[key];
	}

	bool isKeyUp(u16 key)
	{
		return !keys[key];
	}
}

class Keyboard
{
	static KeyboardState* getState() { return new KeyboardState(keys[]); }

	private static void setKey(u16 key, bool state)
	{
		keys[key] = state;
	}

	private static bool[] keys = new bool[65536];
}

struct MouseState
{
	vec2 position;
	bool[] buttons = new bool[8];
	
	bool isButtonDown(u8 button)
	{
		return buttons[button];
	}

	bool isKeyUp(u8 button)
	{
		return !buttons[button];
	}
}

class Mouse
{
	static MouseState* getState() { return new MouseState(position, buttons[]); }

	private static void setPosition(i32 x, i32 y)
	{
		position = vec2(x, y);
	}

	private static vec2 position;
	private static bool[] buttons = new bool[8];
}

class DesktopView : IView
{
	this(string title, u32vec2 size = u32vec2(320, 240)) { m_name = title; m_size = size; }
	this(string title, u32 width, u32 height) { this(title, u32vec2(width, height)); }
	~this() {}

	override void create(IRenderer renderer)
	{
		if(renderer is null)
		{
			stderr.writeln("renderer == null // DesktopView (#", &this, ")");
			m_valid = false;
			return;
		}

		m_renderer = renderer;
		
		DerelictSDL2.load();
		SDL_Init(SDL_INIT_VIDEO);

		m_window = SDL_CreateWindow(m_name.ptr, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, cast(int)m_size.x, cast(int)m_size.y, SDL_WINDOW_SHOWN | cast(uint)renderer.getSDLOptions());
		if(!m_window)
		{
			throw new Exception("Window failed");
		}

		m_renderer.createContext(0, 0, m_size.x, m_size.y, 32, 16, 0, false, m_window);
		m_valid = true;
	}

	override void destroy()
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

	override bool update(f64 deltaTime)
	{
		if(valid)
		{
			SDL_Event event;
			while (SDL_PollEvent(&event)) {
				switch (event.type) {
				case SDL_QUIT:
					return false;
				case SDL_KEYDOWN:
					Keyboard.setKey(cast(u16)event.key.keysym.sym, true);
					break;
				case SDL_KEYUP:
					Keyboard.setKey(cast(u16)event.key.keysym.sym, false);
					break;
				case SDL_MOUSEMOTION:
					Mouse.setPosition(event.motion.x, event.motion.y);
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

	@property bool valid() { return m_valid; }

	private bool m_valid = false;
	private SDL_Window* m_window;
	private IRenderer m_renderer;
}