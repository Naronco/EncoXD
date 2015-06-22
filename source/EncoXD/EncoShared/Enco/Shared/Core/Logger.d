module Enco.Shared.Core.Logger;

static import std.stdio;
import consoled;
import std.array;

import EncoShared;

class Logger
{
	public static void writeln(S ...)(S args)
	{
		writecln(Fg.gray, "INFO > ", Fg.lightGray, args);
	}

	/// writeln with separator between args
	public static void writesln(T, S ...)(T separator, S args)
	{
		writec(Fg.gray, "INFO > ", Fg.lightGray);
		foreach(i, arg; args)
		{
			if(i != args.length - 1)
				writec(args[i], separator);
			else
				writecln(args[i]);
		}
	}

	/// writeln with format
	public static void writefln(S ...)(S args)
	{
		writec(Fg.gray, "INFO > ", Fg.lightGray);
		std.stdio.writeln(args);
	}

	public static void warnln(S ...)(S args)
	{
		writecln(Fg.yellow, "WARN > ", Fg.lightGray, args);
	}

	/// warnln with separator between args
	public static void warnsln(T, S ...)(T separator, S args)
	{
		writec(Fg.yellow, "WARN > ", Fg.lightGray);
		foreach(i, arg; args)
		{
			if(i != args.length - 1)
				writec(args[i], separator);
			else
				writecln(args[i]);
		}
	}

	/// warnln with format
	public static void warnfln(S ...)(S args)
	{
		writec(Fg.yellow, "WARN > ", Fg.lightGray);
		std.stdio.writeln(args);
	}

	public static void errln(S ...)(S args)
	{
		writecln(Fg.red, "ERROR > ", Fg.lightGray, args);
	}

	/// errln with separator between args
	public static void errsln(T, S ...)(T separator, S args)
	{
		writec(Fg.red, "ERROR > ", Fg.lightGray);
		foreach(i, arg; args)
		{
			if(i != args.length - 1)
				writec(args[i], separator);
			else
				writecln(args[i]);
		}
	}

	/// errln with format
	public static void errfln(S ...)(S args)
	{
		writec(Fg.red, "ERROR > ", Fg.lightGray);
		std.stdio.writeln(args);
	}

	public static void errln(Exception e)
	{
		writecln(Fg.red, "ERROR > ", Fg.lightGray, e.file, "@", e.line, ": ", e.msg);
	}
}

class LuaLogger
{
	public static void writeln(S)(S[] args ...)
	{
		writec(Fg.gray, "LUA INFO > ", Fg.lightGray);
		foreach (param; args)
			std.stdio.write(param);
		std.stdio.writeln();
	}

	public static void warnln(S)(S[] args ...)
	{
		writec(Fg.yellow, "LUA WARN > ", Fg.lightGray);
		foreach (param; args)
			std.stdio.write(param);
		std.stdio.writeln();
	}

	public static void errln(S)(S[] args ...)
	{
		writec(Fg.red, "LUA ERROR > ", Fg.lightGray);
		foreach (param; args)
			std.stdio.write(param);
		std.stdio.writeln();
	}
}
