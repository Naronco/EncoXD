module Enco.Shared.TemplateParser;

import std.array;

class TemplateParser
{
	/// Converts Shader Templates.
	/// converts from @{name} defined in variables
	static string parse(string content, const string[string] variables)
	{
		foreach(string name, string value; variables)
		{
			content = content.replace("@{" ~ name ~ "}", value);
		}

		return content;
	}
}