module Enco.Shared.Core.EncoContext;

import std.json;
import std.datetime;

import EncoShared;

enum DynamicLibrary
{
	Assimp, SDL2, SDL2Image, SDL2TTF, Lua,
}

struct MouseEvent
{
	vec2 position;
	vec2 offset;
	u8 button;
}

class EncoContext
{
	public static EncoContext instance;
	public string settings;
	public LuaState lua;
	
	public Trigger onClose = new Trigger;
	public Event!i32vec2 onScroll = new Event!i32vec2;
	public Event!string onFileDrop = new Event!string;
	public Event!u32 onKeyDown = new Event!u32;
	public Event!u32 onKeyUp = new Event!u32;
	public Event!MouseEvent onMouseMove = new Event!MouseEvent;
	public Event!MouseEvent onMouseButtonDown = new Event!MouseEvent;
	public Event!MouseEvent onMouseButtonUp = new Event!MouseEvent;
	public Event!i32 onControllerAdded = new Event!i32;
	public Event!i32 onControllerRemoved = new Event!i32;
	public Event!(Tuple!(i32, u8, i16)) onControllerAxis = new Event!(Tuple!(i32, u8, i16));
	public Event!(Tuple!(i32, i8)) onControllerButtonDown = new Event!(Tuple!(i32, i8));
	public Event!(Tuple!(i32, i8)) onControllerButtonUp = new Event!(Tuple!(i32, i8));

	public @property f64 deltaTime() { return delta.to!("seconds", f64); }

	public @property IRenderer renderer() { return view.renderer; }
	public @property IView view() { return m_currentView; }

	private IView[] m_views;
	private IView m_currentView;

	public DynamicLibrary[] loaded;

	private StopWatch sw;
	private TickDuration delta;

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
		foreach(DynamicLibrary lib; libs)
		{
			switch(lib)
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
				if(TTF_Init() == -1)
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
		if((type in lua_events) is null) lua_events[type] = [];
		lua_events[type].length++;
		lua_events[type][lua_events[type].length - 1] = func;
	}

	public void luaEmit(A...)(string type, A args)
	{
		type = type.toLower().trim();
		if((type in lua_events) !is null)
			foreach(ref LuaFunction func; lua_events[type])
			{
				func(args);
			}
	}

	public void luaEmitSingle(string type)
	{
		type = type.toLower().trim();
		if((type in lua_events) !is null)
			foreach(ref LuaFunction func; lua_events[type])
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
		lua["print"] = &LuaLogger.writeln!LuaObject;
		lua["printerr"] = &LuaLogger.errln!LuaObject;
		lua["printwarn"] = &LuaLogger.warnln!LuaObject;
		lua["on"] = &luaOn;
		lua["emit"] = &luaEmit!LuaObject;
		lua["emite"] = &luaEmitSingle;
		lua = LuaExt.apply(lua);

		lua.setPanicHandler(&panic);
		return lua;
	}

	public void importSettings(string jsonStr)
	{
		settings = jsonStr;
		JSONValue json = parseJSON(jsonStr);

		foreach(ref IView view; m_views)
		{
			m_currentView = view;
			view.renderer.importSettings(json);
			view.importSettings(json);
		}
	}

	public void start()
	{
		foreach(ref IView view; m_views)
		{
			m_currentView = view;
			view.create();

			view.scene.view = view;

			if(view.scene !is null)
			{
				if(view.renderer !is null)
					view.scene.renderer = view.renderer;
				view.scene.init();
			}
		
			if(view.renderer !is null)
				view.renderer.postImportSettings(parseJSON(settings));
		}
	}

	public void stop()
	{
		foreach(ref IView view; m_views)
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

		if(m_views.length == 0)
		{
			SDL_Event evt;
			evt.type = SDL_QUIT;
			SDL_PushEvent(&evt);
		}
	}

	public bool update()
	{
		sw.start();
		foreach(ref IView view; m_views)
		{
			m_currentView = view;
			view.performUpdate(delta.to!("seconds", f64));
		}
		luaEmitSingle("update");

		Mouse.setOffset(0, 0);
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			if(event.type == SDL_QUIT)
			{
				onClose(this);
				return false;
			}
			else
			{
				foreach(ref IView view; m_views)
					view.handleEvent(event);
				switch(event.type)
				{
					case SDL_DROPFILE:
						string file = fromStringz(event.drop.file).dup;
						SDL_free(event.drop.file);
						onFileDrop(this, file);
						break;
					case SDL_KEYDOWN:
						Keyboard.setKey(event.key.keysym.sym, true);
						onKeyDown(this, event.key.keysym.sym);
						break;
					case SDL_KEYUP:
						Keyboard.setKey(event.key.keysym.sym, false);
						onKeyUp(this, event.key.keysym.sym);
						break;
					case SDL_MOUSEWHEEL:
						onScroll(this, i32vec2(event.wheel.x, event.wheel.y));
						break;
					case SDL_MOUSEMOTION:
						Mouse.setPosition(event.motion.x, event.motion.y);
						Mouse.addOffset(event.motion.xrel, event.motion.yrel);
						onMouseMove(this, MouseEvent(vec2(event.motion.x, event.motion.y), vec2(event.motion.xrel, event.motion.yrel), 255));
						break;
					case SDL_MOUSEBUTTONDOWN:
					case SDL_MOUSEBUTTONUP:
						Mouse.setPosition(event.button.x, event.button.y);
						Mouse.setButton(event.button.button, event.button.state == SDL_PRESSED);
						if(event.button.state == SDL_PRESSED)
							onMouseButtonDown(this, MouseEvent(vec2(event.button.x, event.button.y), vec2(0, 0), event.button.button));
						else
							onMouseButtonUp(this, MouseEvent(vec2(event.button.x, event.button.y), vec2(0, 0), event.button.button));
						break;
					case SDL_CONTROLLERDEVICEADDED:
						onControllerAdded(this, event.cdevice.which);
						Controller.setConnected(event.cdevice.which, true);
						SDL_GameControllerOpen(event.cdevice.which);
						break;
					case SDL_CONTROLLERDEVICEREMOVED:
						onControllerRemoved(this, event.cdevice.which);
						Controller.setConnected(event.cdevice.which, false);
						break;
					case SDL_CONTROLLERBUTTONDOWN:
					case SDL_CONTROLLERBUTTONUP:
						Controller.setKey(event.cbutton.which, event.cbutton.button, event.cbutton.state == SDL_PRESSED);
						if(event.cbutton.state == SDL_PRESSED)
							onControllerButtonDown(this, Tuple!(i32, i8)(event.cbutton.which, event.cbutton.button));
						else
							onControllerButtonUp(this, Tuple!(i32, i8)(event.cbutton.which, event.cbutton.button));
						break;
					case SDL_CONTROLLERAXISMOTION:
						i16 value = event.caxis.value;
						if(value < -32767) value = -32767;
						if((event.caxis.axis == 0 || event.caxis.axis == 1) && abs(value) < 7849)
						{
							value = 0;
						}
						if((event.caxis.axis == 2 || event.caxis.axis == 3) && abs(value) < 8689)
						{
							value = 0;
						}
						if((event.caxis.axis == 4 || event.caxis.axis == 5) && abs(value) < 30)
						{
							value = 0;
						}
						Controller.setAxis(event.caxis.which, event.caxis.axis, value);
						onControllerAxis(this, Tuple!(i32, u8, i16)(event.caxis.which, event.caxis.axis, value));
						break;
					default: break;
				}
			}
		}
		return true;
	}

	public void draw()
	{
		foreach(ref IView view; m_views)
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
