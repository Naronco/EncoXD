module Enco.Shared.Level.LevelLoader;

private enum ParsingState
{
	Identifier,
	Text,
	Build
}

private enum InterpretingState
{
	Type,
	Name,
	ArgumentValue,
	ArgumentName
}

private class LevelCompiler
{
private:
	import std.string;
	import std.conv;
	import std.ascii;

	ParsingState currentParsingState = ParsingState.Text;
	InterpretingState currentInterpretingState = InterpretingState.Type;

	string content;

	string[] stack = [""];
	string[] arguments;
	string entryType = "";
	int loopCount = 0;
	string code = "";
	int nameIndex = 1;

	void parseType()
	{
		string typeName = content.munch("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_");
		if(typeName.length > 0)
		{
			entryType = typeName;
			stack[stack.length - 1] = "_" ~ typeName.toLower() ~ to!string(nameIndex++);
		}
		currentParsingState = ParsingState.Identifier;
	}

	void parseName()
	{
		int index = content.indexOf(">");
		if(index == -1)
		{
			throw new Exception("Unclosed name");
		}
		nameIndex--;
		stack[stack.length - 1] = content[0 .. index];
		content = content[(index + 1) .. $];
		currentParsingState = ParsingState.Identifier;
	}

	void parseArgumentName()
	{
		int index = content.indexOf("=");

		if(index == -1)
		{
			throw new Exception("Invalid argument at " ~ content);
		}

		arguments ~= "." ~ content[0 .. index] ~ "(";
		content = content[(index + 1) .. $];
		currentInterpretingState = InterpretingState.ArgumentValue;
	}

	void parseArgumentValue()
	{
		int comma = content.indexOf(",");
		if(comma == -1)
			comma = ptrdiff_t.max;
		int end = content.indexOf(")");
		if(end == -1)
			end = ptrdiff_t.max;

		if(comma < end)
		{
			arguments[arguments.length - 1] ~= content[0 .. comma] ~ ")";
			content = content[(comma + 1) .. $];
			currentInterpretingState = InterpretingState.ArgumentName;
		}
		else
		{
			arguments[arguments.length - 1] ~= content[0 .. end] ~ ")";
			content = content[(end + 1) .. $];
			currentParsingState = ParsingState.Identifier;
		}
	}

	void parseIdentifier()
	{
		char type = content[0];
		currentParsingState = ParsingState.Text;
		if(type == '<')
		{
			content = content[1 .. $];
			content = content.strip();
			currentInterpretingState = InterpretingState.Name;
		}
		else if(type == '(')
		{
			content = content[1 .. $];
			content = content.strip();
			currentInterpretingState = InterpretingState.ArgumentName;
		}
		else if(type == '{')
		{
			currentParsingState = ParsingState.Build;
		}
		else if(type == '}')
		{
			currentParsingState = ParsingState.Build;
		}
		else if(type.isAlpha())
		{
			currentParsingState = ParsingState.Build;
		}
		else
		{
			content = content[1 .. $];
			content = content.strip();
			currentParsingState = ParsingState.Build;
		}
	}

public:

	string compileLevel(string content_)
{
	content = content_.strip();
	while(true)
	{
		content = content.strip();
		if(content.length == 0)
			break;

		// std.stdio.writefln("stack [%(%s, %)], type \"%s\", arguments \"%s\"\nparse \"%s\", interpret \"%s\"\nremaining \"%s\"\ncode \"%s\"\n", stack, entryType, arguments.join(), currentParsingState, currentInterpretingState, content, code);

		loopCount++;
		if(loopCount > 1000000)
			throw new Exception("Stuck in compiling level, Aborting!");

		if(currentParsingState == ParsingState.Text)
		{
			if(currentInterpretingState == InterpretingState.Type)
			{
				parseType();
				continue;
			}
			else if(currentInterpretingState == InterpretingState.Name)
			{
				parseName();
				continue;
			}
			else if(currentInterpretingState == InterpretingState.ArgumentName)
			{
				parseArgumentName();
				continue;
			}
			else if(currentInterpretingState == InterpretingState.ArgumentValue)
			{
				parseArgumentValue();
				continue;
			}
		}
		else if(currentParsingState == ParsingState.Identifier)
		{
			parseIdentifier();
			continue;
		}
		else
		{
			code ~= //entryType ~ " " ~
				stack[stack.length - 1]
				~ " = new " ~ entryType
				~ "()" ~ arguments.join() ~ ";\n";
			arguments.length = 0;
			if(stack.length > 1)
			{
				code ~= stack[stack.length - 2] ~ ".addChild(" ~ stack[stack.length - 1] ~ ");\n";
			}
			currentParsingState = ParsingState.Text;
			currentInterpretingState = InterpretingState.Type;

		Stacker:
			while(true)
			{
				if(content.length == 0) break Stacker;
				if(content[0] == '{')
				{
					content = content[1 .. $];
					content = content.strip();
					stack.length++;
				}
				else if(content[0] == '}')
				{
					content = content[1 .. $];
					content = content.strip();
					stack.length--;
				}
				else
				{
					break Stacker;
				}
			}
		}
	}
	return code;
}
}

mixin template compileLevel(string content_, string append = "")
{
	void compile()
	{
		enum code = new LevelCompiler().compileLevel(content_);
		mixin(code ~ append);
	}
}

unittest
{
	import std.stdio;
	import std.string;

	class A
	{
		public A[] children;

		public int _value = -1;

		public this() {}

		public void addChild(A a)
		{
			children ~= a;
		}

		public @property int value()
		{
			return _value;
		}

		public @property A value(int val)
		{
			_value = val;
			return this;			
		}
	}

	A name1, _a1, name2, name3, name4, _a2;
	mixin compileLevel!("A<name1> { A(value=5) A<name2>(value=4) A<name3>(value=3) { A<name4>(value=2) { A(value=1) } } }") ExampleLevel;
	ExampleLevel.compile();
	assert(name1.value == -1);
	assert(_a1.value == 5);
	assert(name2.value == 4);
	assert(name3.value == 3);
	assert(name4.value == 2);
	assert(_a2.value == 1);
}