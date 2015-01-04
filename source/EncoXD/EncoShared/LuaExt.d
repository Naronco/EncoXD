module Enco.Shared.LuaExt;

import std.traits;
import core.thread;
import std.socket;

import EncoShared;

class LuaThread : Thread
{
	public LuaFunction fnc;

	public this(LuaFunction fnc)
	{
		super(&run);
		this.fnc = fnc;
	}

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