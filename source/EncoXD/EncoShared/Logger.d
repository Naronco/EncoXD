module Enco.Shared.Logger;

import EncoShared;

class Logger
{
	static void writeln(S...)(S args)
	{
		std.stdio.writeln("INFO > ", args);
	}

	static void warnln(S...)(S args)
	{
		std.stdio.writeln("WARN > ", args);
	}

	static void errln(S...)(S args)
	{
		std.stdio.writeln("ERROR > ", args);
	}

	static void errln(Exception e)
	{
		std.stdio.writeln("ERROR > ", e.file, "@", e.line, ": ", e.msg);
	}
}