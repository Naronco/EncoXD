module Enco.Shared.LuaExt;

import std.traits;
import core.thread;
import std.socket;

import EncoShared;

class LuaThread : Thread
{
	LuaFunction fnc;

	this(LuaFunction fnc)
	{
		super(&run);
		this.fnc = fnc;
	}

	private void run()
	{
		fnc.call();
	}

	static void createThread(LuaFunction fnc)
	{
		new LuaThread(fnc).start();
		LuaLogger.writeln("Started new Thread (", fnc.object.toString(), ")");
	}
}

class LuaExt
{
	static LuaTable threadModule(LuaState lua)
	{
		auto lib = lua.newTable();

		lib["start"] = &LuaThread.createThread;
		lib["yield"] = &Fiber.yield;

		return lib;
	}

	static LuaState apply(LuaState state)
	{
		state["thread"] = threadModule(state);

		return state;
	}
}