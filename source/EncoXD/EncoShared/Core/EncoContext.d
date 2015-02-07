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

	public Event!bool onClose = new Event!bool;
	public Event!u32vec2 onResize = new Event!u32vec2;
	public Event!u32 onKeyDown = new Event!u32;
	public Event!u32 onKeyUp = new Event!u32;
	public Event!MouseEvent onMouseMove = new Event!MouseEvent;
	public Event!MouseEvent onMouseButtonDown = new Event!MouseEvent;
	public Event!MouseEvent onMouseButtonUp = new Event!MouseEvent;

	public DynamicLibrary[] loaded;

	private StopWatch sw;
	private TickDuration delta;
	
	public LuaFunction[][string] lua_events;

	public static void create(IView mainView, IRenderer renderer, Scene scene)
	{
		assert(instance is null);
		instance = new EncoContext(mainView, renderer, scene);
	}

	public static void create()
	{
		assert(instance is null);
		instance = new EncoContext(null, null, null);
	}

	private this(IView mainView, IRenderer renderer, Scene scene)
	{
		m_mainView = mainView;
		m_renderer = renderer;
		m_scene = scene;
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
		
		if(m_renderer !is null)
			m_renderer.importSettings(json);
		if(m_mainView !is null)
			m_mainView.importSettings(json);
	}

	public void start()
	{
		if(m_renderer !is null)
			m_mainView.create(m_renderer);
		
		if(m_scene !is null)
		{
			if(m_renderer !is null)
				m_scene.renderer = m_renderer;
			if(m_mainView !is null)
				m_scene.view = m_mainView;
			m_scene.init();
		}
		
		if(m_renderer !is null)
			m_renderer.postImportSettings(parseJSON(settings));
	}

	public void stop()
	{
		if(m_scene !is null)
			m_scene.destroy();
		if(m_mainView !is null)
			m_mainView.destroy();
	}

	public bool update()
	{
		sw.start();
		if(m_scene !is null)
			if(!m_scene.update(delta.to!("seconds", f64)))
			{
				m_scene.destroy();
				m_scene = m_scene.next;
				m_scene.init();
			}
		luaEmitSingle("update");
		if(m_mainView !is null)
			return m_mainView.update(delta.to!("seconds", f64));
		else
			return false;
	}

	public void draw3D(RenderContext context)
	{
		luaEmitSingle("draw3D");
		if(m_scene !is null)
			m_scene.draw3D(context, m_renderer);
	}

	public void draw2D()
	{
		luaEmitSingle("draw2D");
		if(m_scene !is null)
			m_scene.draw2D(m_renderer.gui);
	}

	public void endUpdate()
	{
		sw.stop();
		delta = sw.peek();
		sw.reset();
	}

	public @property f64 deltaTime() { return delta.to!("seconds", f64); }

	public @property Scene scene() { return m_scene; }
	public @property IView view() { return m_mainView; }
	public @property IRenderer renderer() { return m_renderer; }

	private IView m_mainView;
	private IRenderer m_renderer;
	private Scene m_scene;
}