module Enco.Shared.EncoContext;

import std.json;
import std.string;
import std.conv;

import EncoShared;

enum DynamicLibrary
{
	Assimp, SDL2, SDL2Image, Lua, 
}

class EncoContext
{
	static EncoContext instance;
	string settings;
	LuaState lua;
	
	LuaFunction[][string] lua_events;

	static void create(IView mainView, IRenderer renderer, Scene scene)
	{
		assert(instance is null);
		instance = new EncoContext(mainView, renderer, scene);
	}

	private this(IView mainView, IRenderer renderer, Scene scene)
	{
		m_mainView = mainView;
		m_renderer = renderer;
		m_scene = scene;
		
		assert(m_mainView !is null);
		assert(m_renderer !is null);
		assert(m_scene !is null);
	}

	~this()
	{
	}

	void useDynamicLibraries(const DynamicLibrary[] libs)
	{
		foreach(DynamicLibrary lib; libs)
		{
			switch(lib)
			{
			case DynamicLibrary.Assimp:
				DerelictASSIMP3.load();
				break;
			case DynamicLibrary.SDL2:
				DerelictSDL2.load();
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

	void luaOn(string type, LuaFunction func)
	{
		type = type.toLower().trim();
		if((type in lua_events) is null) lua_events[type] = [];
		lua_events[type].length++;
		lua_events[type][lua_events[type].length - 1] = func;
	}

	void luaEmit(A)(string type, A[] args...)
	{
		type = type.toLower().trim();
		if((type in lua_events) !is null)
			foreach(ref LuaFunction func; lua_events[type])
			{
				func(args);
			}
	}

	void luaEmitSingle(string type)
	{
		type = type.toLower().trim();
		if((type in lua_events) !is null)
			foreach(ref LuaFunction func; lua_events[type])
			{
				func();
			}
	}

	static void panic(LuaState lua, in char[] error)
	{
		string err = error.idup;
		LuaLogger.errln("in script ", lua.get!LuaTable("info").get!string("name"), "\n\t", err);
	}

	LuaState createLuaState()
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

	void importSettings(string jsonStr)
	{
		settings = jsonStr;
		JSONValue json = parseJSON(jsonStr);
		
		renderer.importSettings(json);
		view.importSettings(json);
	}

	void start()
	{
		m_mainView.create(m_renderer);

		m_scene.renderer = m_renderer;
		m_scene.view = m_mainView;
		m_scene.init();

		m_renderer.postImportSettings(parseJSON(settings));
	}

	void stop()
	{
		m_scene.destroy();
		m_mainView.destroy();
	}

	bool update()
	{
		if(!m_scene.update(0))
		{
			m_scene.destroy();
			m_scene = m_scene.next;
			m_scene.init();
		}
		luaEmitSingle("update");
		return m_mainView.update(0); // TODO: Add delta time
	}

	void draw(RenderContext context)
	{
		luaEmitSingle("draw");
		m_scene.draw(context, m_renderer);
	}


	@property Scene scene() { return m_scene; }
	@property IView view() { return m_mainView; }
	@property IRenderer renderer() { return m_renderer; }

	IView getMainView() { return m_mainView; }

	private IView m_mainView;
	private IRenderer m_renderer;
	private Scene m_scene;
}