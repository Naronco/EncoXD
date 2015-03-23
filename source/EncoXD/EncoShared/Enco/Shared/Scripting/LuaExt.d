module Enco.Shared.Scripting.LuaExt;

import std.traits;
import core.thread;
import std.socket;

import EncoShared;

/// Thread creatable from Lua using thread.start(function)
class LuaThread : Thread
{
	public LuaFunction fnc;

	public this(LuaFunction fnc)
	{
		super(&run);
		this.fnc = fnc;
	}

	/// Starts a new thread running fnc
	public static void createThread(LuaFunction fnc)
	{
		new LuaThread(fnc).start();
		LuaLogger.writeln("Started new Thread (", fnc.object.toString(), ")");
	}

	private void run()
	{
		fnc.call();
	}
}

/// Class containing lua functions
class LuaExt
{
	public static LuaTable threadModule(LuaState lua)
	{
		auto lib = lua.newTable();

		lib["start"] = &LuaThread.createThread;

		return lib;
	}

	public static LuaState apply(LuaState state)
	{
		state["thread"] = threadModule(state);

		return state;
	}
}
