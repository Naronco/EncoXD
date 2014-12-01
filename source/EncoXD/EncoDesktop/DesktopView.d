module Enco.Desktop.DesktopView;

import EncoDesktop;
private import std.stdio;

private
{
	import EncoShared;
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