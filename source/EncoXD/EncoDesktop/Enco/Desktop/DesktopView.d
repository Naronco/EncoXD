module Enco.Desktop.DesktopView;

import std.json;
import std.stdio;

import EncoDesktop;
import EncoShared;

class DesktopView : IView
{
	public @property Window window() { return m_window; }
	public @property bool valid() { return m_valid; }

	private bool m_valid = false;
	private Window m_window;
	private IRenderer m_renderer;

	public this(string title, u32vec2 size = u32vec2(320, 240)) { m_name = title; m_size = size; }
	public this(string title, u32 width, u32 height) { this(title, u32vec2(width, height)); }
	public this() { this("", 0, 0); }
	public ~this() {}

	public override void create(IRenderer renderer)
	{
		assert(renderer !is null);

		m_renderer = renderer;

		auto flags = SDL_WINDOW_SHOWN;

		if(m_size.x == 0 && m_size.y == 0)
		{
			SDL_DisplayMode current;

			SDL_GetCurrentDisplayMode(0, &current);

			m_size.x = current.w;
			m_size.y = current.h;

			flags = SDL_WINDOW_BORDERLESS;
		}

		m_window = new Window(m_name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, cast(int)m_size.x, cast(int)m_size.y, flags | cast(uint)renderer.getSDLOptions());
		if(!m_window.valid)
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
					name = json["Window"]["Title"].str;
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

			if(m_window !is null && m_window.valid)
			{
				m_window.destroy();
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
					EncoContext.instance.onClose(this, true);
					return false;
				case SDL_WINDOWEVENT:
					switch(event.window.event)
					{
						case SDL_WINDOWEVENT_SHOWN:
							EncoContext.instance.onShow();
							break;
						case SDL_WINDOWEVENT_HIDDEN:
							EncoContext.instance.onHide();
							break;
						case SDL_WINDOWEVENT_EXPOSED:
							EncoContext.instance.onExpose();
							break;
						case SDL_WINDOWEVENT_MOVED:
							EncoContext.instance.onMove(this, u32vec2(event.window.data1, event.window.data2));
							break;
						case SDL_WINDOWEVENT_RESIZED:
							size = u32vec2(event.window.data1, event.window.data2);
							EncoContext.instance.onResize(this, size);
							break;
						case SDL_WINDOWEVENT_MINIMIZED:
							EncoContext.instance.onMinimize();
							break;
						case SDL_WINDOWEVENT_MAXIMIZED:
							EncoContext.instance.onMaximize();
							break;
						case SDL_WINDOWEVENT_RESTORED:
							EncoContext.instance.onRestore();
							break;
						case SDL_WINDOWEVENT_ENTER:
							EncoContext.instance.onEnter();
							break;
						case SDL_WINDOWEVENT_LEAVE:
							EncoContext.instance.onLeave();
							break;
						case SDL_WINDOWEVENT_FOCUS_GAINED:
							EncoContext.instance.onFocusGain();
							break;
						case SDL_WINDOWEVENT_FOCUS_LOST:
							EncoContext.instance.onFocusLost();
							break;
						default: break;
					}
					break;
				case SDL_KEYDOWN:
					Keyboard.setKey(event.key.keysym.sym, true);
					EncoContext.instance.onKeyDown(this, event.key.keysym.sym);
					break;
				case SDL_KEYUP:
					Keyboard.setKey(event.key.keysym.sym, false);
					EncoContext.instance.onKeyUp(this, event.key.keysym.sym);
					break;
				case SDL_MOUSEWHEEL:
					EncoContext.instance.onScroll(this, i32vec2(event.wheel.x, event.wheel.y));
					break;
				case SDL_MOUSEMOTION:
					Mouse.setPosition(event.motion.x, event.motion.y);
					Mouse.addOffset(event.motion.xrel, event.motion.yrel);
					EncoContext.instance.onMouseMove(this, MouseEvent(vec2(event.motion.x, event.motion.y), vec2(event.motion.xrel, event.motion.yrel), 255));
					break;
				case SDL_MOUSEBUTTONDOWN:
				case SDL_MOUSEBUTTONUP:
					Mouse.setPosition(event.button.x, event.button.y);
					Mouse.setButton(event.button.button, event.button.state == SDL_PRESSED);
					if(event.button.state == SDL_PRESSED)
						EncoContext.instance.onMouseButtonDown(this, MouseEvent(vec2(event.button.x, event.button.y), vec2(0, 0), event.button.button));
					else
						EncoContext.instance.onMouseButtonUp(this, MouseEvent(vec2(event.button.x, event.button.y), vec2(0, 0), event.button.button));
					break;
				case SDL_DROPFILE:
					string file = fromStringz(event.drop.file).dup;
					SDL_free(event.drop.file);
					EncoContext.instance.onFileDrop(this, file);
					break;
				case SDL_CONTROLLERDEVICEADDED:
					EncoContext.instance.onControllerAdded(this, event.cdevice.which);
					Controller.setConnected(event.cdevice.which, true);
					SDL_GameControllerOpen(event.cdevice.which);
					break;
				case SDL_CONTROLLERDEVICEREMOVED:
					EncoContext.instance.onControllerRemoved(this, event.cdevice.which);
					Controller.setConnected(event.cdevice.which, false);
					break;
				case SDL_CONTROLLERBUTTONDOWN:
				case SDL_CONTROLLERBUTTONUP:
					Controller.setKey(event.cbutton.which, event.cbutton.button, event.cbutton.state == SDL_PRESSED);
					if(event.cbutton.state == SDL_PRESSED)
						EncoContext.instance.onControllerButtonDown(this, Tuple!(i32, i8)(event.cbutton.which, event.cbutton.button));
					else
						EncoContext.instance.onControllerButtonUp(this, Tuple!(i32, i8)(event.cbutton.which, event.cbutton.button));
					break;
				case SDL_CONTROLLERAXISMOTION:
					i16 value = event.caxis.value;
					if(value < -32767) value = -32767;
					if(event.caxis.axis < 4 && abs(value) < 4000)
					{
						value = 0;
					}
					if(event.caxis.axis > 3 && abs(value) < 800)
					{
						value = 0;
					}
					Controller.setAxis(event.caxis.which, event.caxis.axis, value);
					EncoContext.instance.onControllerAxis(this, Tuple!(i32, u8, i16)(event.caxis.which, event.caxis.axis, value));
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
			m_window.size = m_size;
		}
	}

	protected override void onRename()
	{
		if(valid)
		{
			m_window.title = m_name;
		}
	}
}
