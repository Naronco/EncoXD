module Enco.Shared.Core.TemplateParser;

import EncoShared;

import std.array;
import std.regex;

class TemplateParser
{
	/// Converts Shader Templates.
	/// converts from @{name} defined in variables
	public static string parse(string content, const string[string] variables)
	{
		foreach(string name, string value; variables)
		{
			content = replace(content, regex(r"@\{" ~ name ~ r"(?::.*?)?\}", "g"), value);
		}
		
		content = replace(content, regex(r"@\{.*?:(.*?)\}", "g"), "$1");
		auto m = match(content, regex(r"@\{(.*?)\}"));
		if(m)
			Logger.errln("Not assigned non default static variable in shader. Replace @{", m.captures[1] ,"} with @{", m.captures[1] ,":<default value>}");
		content = replace(content, regex(r"@\{.*?\}", "g"), "");

		return content;
	}
}