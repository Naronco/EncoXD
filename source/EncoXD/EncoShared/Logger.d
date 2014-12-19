module Enco.Shared.Logger;

import colorize;
import std.array;

import EncoShared;

class Logger
{
	static void writeln(S...)(S args)
	{
		cwriteln("INFO > ".color(fg.light_black), "".color(fg.white), args);
	}

	static void warnln(S...)(S args)
	{
		cwriteln("WARN > ".color(fg.yellow), "".color(fg.white), args);
	}

	static void errln(S...)(S args)
	{
		cwriteln("ERROR > ".color(fg.red), "".color(fg.white), args);
	}

	static void errln(Exception e)
	{
		cwriteln("ERROR > ".color(fg.red), "".color(fg.white), e.file, "@", e.line, ": ", e.msg);
	}
}

class LuaLogger
{
	static void writeln(S)(S[] args...)
	{
		cwrite("LUA INFO > ".color(fg.light_black), "".color(fg.white));
		foreach(param; args)
			std.stdio.write(param);
		std.stdio.writeln();
	}

	static void warnln(S)(S[] args...)
	{
		cwrite("LUA WARN > ".color(fg.yellow), "".color(fg.white));
		foreach(param; args)
			std.stdio.write(param);
		std.stdio.writeln();
	}

	static void errln(S)(S[] args...)
	{
		cwrite("LUA ERROR > ".color(fg.red), "".color(fg.white));
		foreach(param; args)
			std.stdio.write(param);
		std.stdio.writeln();
	}
}