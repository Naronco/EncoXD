module Enco.Shared.Core.EncoContext;

import std.json;
import std.datetime;
import std.typecons;

import EncoShared;

enum DynamicLibrary
{
	Assimp, SDL2, SDL2Image, SDL2TTF, Lua,
}

struct FileDropEvent
{
	u32	   timestamp;
	string file;
}

class EncoContext
{
	public static EncoContext instance;
	public string			  settings;
	public LuaState			  lua;

	public Trigger onClose = new Trigger;
	public Event!MouseWheelEvent onScroll = new Event!MouseWheelEvent;
	public Event!FileDropEvent onFileDrop = new Event!FileDropEvent;
	public Event!KeyDownEvent onKeyDown = new Event!KeyDownEvent;
	public Event!KeyUpEvent onKeyUp = new Event!KeyUpEvent;
	public Event!MouseMoveEvent onMouseMove = new Event!MouseMoveEvent;
	public Event!MouseButtonDownEvent onMouseButtonDown = new Event!MouseButtonDownEvent;
	public Event!MouseButtonUpEvent onMouseButtonUp = new Event!MouseButtonUpEvent;
	public Event!ControllerAddedEvent onControllerAdded = new Event!ControllerAddedEvent;
	public Event!ControllerRemovedEvent onControllerRemoved = new Event!ControllerRemovedEvent;
	public Event!ControllerAxisEvent onControllerAxis = new Event!ControllerAxisEvent;
	public Event!ControllerButtonDownEvent onControllerButtonDown = new Event!ControllerButtonDownEvent;
	public Event!ControllerButtonUpEvent onControllerButtonUp = new Event!ControllerButtonUpEvent;

	public @property f64 deltaTime()
	{
		return delta.to!("seconds", f64);
	}

	public @property IRenderer renderer()
	{
		return view.renderer;
	}
	public @property IView view()
	{
		return m_currentView;
	}

	private IView[]			m_views;
	private IView			m_currentView;

	public DynamicLibrary[] loaded;

	private StopWatch		sw;
	private TickDuration	delta;

	public LuaFunction[][string] lua_events;

	public static void create(const DynamicLibrary[] libs)
	{
		assert(instance is null);
		instance = new EncoContext(libs);
	}

	private this(const DynamicLibrary[] libs)
	{
		useDynamicLibraries(libs);
	}

	public ~this()
	{
	}

	public void useDynamicLibraries(const DynamicLibrary[] libs)
	{
		loaded ~= libs;
		foreach (DynamicLibrary lib; libs)
		{
			switch (lib)
			{
			case DynamicLibrary.Assimp:
				DerelictASSIMP3.load();
				break;
			case DynamicLibrary.SDL2:
				DerelictSDL2.load();
				DerelictGL3.load();
				SDL_Init(SDL_INIT_EVERYTHING);
				break;
			case DynamicLibrary.SDL2TTF:
				DerelictSDL2ttf.load();
				if (TTF_Init() == -1)
				{
					Logger.errln("Error Initializing SDL_TTF: ", TTF_GetError());
				}
				break;
			case DynamicLibrary.SDL2Image:
				DerelictSDL2Image.load();
				break;
			case DynamicLibrary.Lua:
				lua = createLuaState();
				break;
			default:
				break;
			}
		}
	}

	public void luaOn(string type, LuaFunction func)
	{
		type = type.toLower().trim();
		if ((type in lua_events) is null)
			lua_events[type] = [];
		lua_events[type].length++;
		lua_events[type][lua_events[type].length - 1] = func;
	}

	public void luaEmit(A ...)(string type, A args)
	{
		type = type.toLower().trim();
		if ((type in lua_events) !is null)
			foreach (ref LuaFunction func; lua_events[type])
			{
				func(args);
			}
	}

	public void luaEmitSingle(string type)
	{
		type = type.toLower().trim();
		if ((type in lua_events) !is null)
			foreach (ref LuaFunction func; lua_events[type])
			{
				func();
			}
	}

	public static void panic(LuaState lua, in char[] error)
	{
		string err = error.idup;
		LuaLogger.errln("in script ", lua.get!LuaTable("info").get!string("name"), "\n\t", err);
	}

	public LuaState createLuaState()
	{
		auto lua = new LuaState;
		lua.openLibs();
		lua["print"]	 = &LuaLogger.writeln!LuaObject;
		lua["printerr"]	 = &LuaLogger.errln!LuaObject;
		lua["printwarn"] = &LuaLogger.warnln!LuaObject;
		lua["on"]		 = &luaOn;
		lua["emit"]		 = &luaEmit!LuaObject;
		lua["emite"]	 = &luaEmitSingle;
		lua				 = LuaExt.apply(lua);

		lua.setPanicHandler(&panic);
		return lua;
	}

	public void importSettings(string jsonStr)
	{
		settings = jsonStr;
		JSONValue json = parseJSON(jsonStr);

		foreach (ref IView view; m_views)
		{
			m_currentView = view;
			view.renderer.importSettings(json);
			view.importSettings(json);
		}
	}

	public void start()
	{
		foreach (ref IView view; m_views)
		{
			m_currentView = view;
			view.doCreate();

			if (view.renderer !is null)
				view.renderer.postImportSettings(parseJSON(settings));
		}
	}

	public void stop()
	{
		foreach (ref IView view; m_views)
			view.destroy();
	}

	public void addView(TRenderer : IRenderer)(IView view)
	{
		view.renderer = new TRenderer();
		m_views ~= view;
	}

	public void removeView(IView view)
	{
		m_views = remove!(v => v == view)(m_views);

		if (m_views.length == 0)
		{
			SDL_Event evt;
			evt.type = SDL_QUIT;
			SDL_PushEvent(&evt);
		}
	}

	public bool update()
	{
		sw.start();
		foreach (ref IView view; m_views)
		{
			m_currentView = view;
			view.performUpdate(delta.to!("seconds", f64));
		}
		luaEmitSingle("update");

		Mouse.setOffset(0, 0);
		SDL_Event event;
		while (SDL_PollEvent(&event))
		{
			if (event.type == SDL_QUIT)
			{
				onClose(this);
				return false;
			}
			else
			{
				foreach (ref IView view; m_views)
					view.handleEvent(event);
				switch (event.type)
				{
				case SDL_DROPFILE:
					string		  file = fromStringz(event.drop.file).dup;
					SDL_free(event.drop.file);
					FileDropEvent e;
					e.timestamp = event.drop.timestamp;
					e.file		= file;
					onFileDrop(this, e);
					break;
				case SDL_KEYDOWN:
					Keyboard.setKey(event.key.keysym.sym, true);
					KeyDownEvent e;
					e.timestamp = event.key.timestamp;
					e.window	= event.key.windowID;
					e.state		= event.key.state;
					e.repeat	= event.key.repeat;
					e.keyID		= event.key.keysym.sym;
					onKeyDown(this, e);
					break;
				case SDL_KEYUP:
					Keyboard.setKey(event.key.keysym.sym, false);
					KeyUpEvent e;
					e.timestamp = event.key.timestamp;
					e.window	= event.key.windowID;
					e.state		= event.key.state;
					e.repeat	= event.key.repeat;
					e.keyID		= event.key.keysym.sym;
					onKeyUp(this, e);
					break;
				case SDL_MOUSEWHEEL:
					MouseWheelEvent e;
					e.timestamp = event.wheel.timestamp;
					e.windowID	= event.wheel.windowID;
					e.id		= event.wheel.which;
					e.amount	= i32vec2(event.wheel.x, event.wheel.y);
					e.flipped	= event.wheel.direction == SDL_MOUSEWHEEL_FLIPPED;
					onScroll(this, e);
					break;
				case SDL_MOUSEMOTION:
					Mouse.setPosition(event.motion.x, event.motion.y);
					Mouse.addOffset(event.motion.xrel, event.motion.yrel);
					MouseMoveEvent e;
					e.position	= i32vec2(event.motion.x, event.motion.y);
					e.offset	= i32vec2(event.motion.xrel, event.motion.yrel);
					e.id		= event.motion.which;
					e.windowID	= event.motion.windowID;
					e.timestamp = event.motion.timestamp;
					onMouseMove(this, e);
					break;
				case SDL_MOUSEBUTTONDOWN:
				case SDL_MOUSEBUTTONUP:
					Mouse.setPosition(event.button.x, event.button.y);
					Mouse.setButton(event.button.button, event.button.state == SDL_PRESSED);
					if (event.button.state == SDL_PRESSED)
					{
						MouseButtonDownEvent e;
						e.buttonID	= event.button.button;
						e.position	= i32vec2(event.button.x, event.button.y);
						e.id		= event.button.which;
						e.windowID	= event.button.windowID;
						e.timestamp = event.button.timestamp;
						e.state		= event.button.state;

						onMouseButtonDown(this, e);
					}
					else
					{
						MouseButtonUpEvent e;
						e.buttonID	= event.button.button;
						e.position	= i32vec2(event.button.x, event.button.y);
						e.id		= event.button.which;
						e.windowID	= event.button.windowID;
						e.timestamp = event.button.timestamp;
						e.state		= event.button.state;

						onMouseButtonUp(this, e);
					}
					break;
				case SDL_CONTROLLERDEVICEADDED:
					ControllerAddedEvent e;
					e.timestamp = event.cdevice.timestamp;
					e.id		= event.cdevice.which;
					onControllerAdded(this, e);
					Controller.setConnected(event.cdevice.which, true);
					SDL_GameControllerOpen(event.cdevice.which);
					break;
				case SDL_CONTROLLERDEVICEREMOVED:
					ControllerRemovedEvent e;
					e.timestamp = event.cdevice.timestamp;
					e.id		= event.cdevice.which;
					onControllerRemoved(this, e);
					Controller.setConnected(event.cdevice.which, false);
					break;
				case SDL_CONTROLLERBUTTONDOWN:
				case SDL_CONTROLLERBUTTONUP:
					Controller.setKey(event.cbutton.which, event.cbutton.button, event.cbutton.state == SDL_PRESSED);
					if (event.cbutton.state == SDL_PRESSED)
					{
						ControllerButtonDownEvent e;
						e.timestamp = event.cbutton.timestamp;
						e.id		= event.cbutton.which;
						e.buttonID	= event.cbutton.button;
						e.state		= event.cbutton.state;
						onControllerButtonDown(this, e);
					}
					else
					{
						ControllerButtonUpEvent e;
						e.timestamp = event.cbutton.timestamp;
						e.id		= event.cbutton.which;
						e.buttonID	= event.cbutton.button;
						e.state		= event.cbutton.state;
						onControllerButtonUp(this, e);
					}
					break;
				case SDL_CONTROLLERAXISMOTION:
					i16 value = event.caxis.value;
					if (value < -32767)
						value = -32767;
					if ((event.caxis.axis == 0 || event.caxis.axis == 1) && abs(value) < 7849)
					{
						value = 0;
					}
					if ((event.caxis.axis == 2 || event.caxis.axis == 3) && abs(value) < 8689)
					{
						value = 0;
					}
					if ((event.caxis.axis == 4 || event.caxis.axis == 5) && abs(value) < 30)
					{
						value = 0;
					}
					Controller.setAxis(event.caxis.which, event.caxis.axis, value);
					ControllerAxisEvent e;
					e.timestamp = event.caxis.timestamp;
					e.id		= event.caxis.which;
					e.axisID	= event.caxis.axis;
					e.value		= value;
					onControllerAxis(this, e);
					break;
				default: break;
				}
			}
		}
		return true;
	}

	public void draw()
	{
		foreach (ref IView view; m_views)
		{
			m_currentView = view;
			view.performDraw();
		}
	}

	public void endUpdate()
	{
		sw.stop();
		delta = sw.peek();
		sw.reset();
	}
}
