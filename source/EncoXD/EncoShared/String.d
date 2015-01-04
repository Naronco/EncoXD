module Enco.Shared.Ext.String;

import std.algorithm;

pure bool contains(string source, string str)
{
	return canFind(source, str);
}

public alias std.string.strip trim;
public alias std.string.stripLeft trimStart;
public alias std.string.stripRight trimEnd;