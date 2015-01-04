module Enco.Shared.Animation.Animation;

import EncoShared;

class AnimationFunctions
{
	mixin BasicEase;
}

struct DoubleDoublePair
{
	public f64 a;
	public f64 b;

	public string toString()
	{
		return format("%g;%g", a, b);
	}
}

struct AnimatedProperty
{
	public string name;
	public string[] functions;
	public DoubleDoublePair[] keyframes;

	public string toString()
	{
		return format("%s = %s -> %s", name, functions, keyframes);
	}

	public @property AnimatedProperty dup()
	{
		AnimatedProperty b;
		b.name = name;
		b.functions = functions.dup;
		b.keyframes = keyframes.dup;
		return b;
	}
}

alias EasingFunction = f64 function(f64, f64, f64);

class Animation
{
	private f64 currentTime = 0;
	private f64 iLengthInSec = 0;
	private AnimatedProperty[] props;

	public f64[string] properties;
	public f64 time = 0;

	public this(int ms, string storyboard)
	{
		string[] lines = storyboard.split('\n');
		iLengthInSec = 1 / (ms * 0.001);

		AnimatedProperty current = AnimatedProperty();
		current.name = null;

		bool cmp(DoubleDoublePair x, DoubleDoublePair y) @safe pure nothrow { return x.a < y.a; }

		foreach(int i, string line; lines)
		{
			line = line.trim();

			if(line.length == 0) continue;
			if(line[0] == '#') continue;
			if(line[0] == '!')
			{
				if(current.name !is null)
				{
					assert(current.keyframes.length > 1, "At least 2 keyframes needed!");
					sort!cmp(current.keyframes);
					assert(isSorted!cmp(current.keyframes));
					props ~= current.dup;
				}
				current.name = line.trim()[1 .. $];
				current.keyframes.length = 0;
			}
			else
			{
				string[] splits = line.split(' ');
				current.functions ~= splits[0].toLower();
				f64 t, val;
				
				t = to!f64(splits[1].trim());
				val = to!f64(splits[2].trim());

				current.keyframes ~= DoubleDoublePair(t, val);
			}
		}

		if(current.name !is null)
		{
			assert(current.keyframes.length > 1, "At least 2 keyframes needed!");
			sort!(cmp)(current.keyframes);
			assert(isSorted!cmp(current.keyframes));
			props ~= current.dup;
		}

		foreach(prop; props)
			properties[prop.name] = 0;
	}

	public f64 get(string name)
	{
		if((name in properties) !is null)
			return properties[name];
		return 0;
	}

	public void update(f64 delta)
	{
		currentTime += delta;
		time = currentTime * iLengthInSec;

		if(time > 1)
			time = 1;

		foreach(prop; props)
		{
			for(int i = prop.keyframes.length - 2; i >= 0; i--)
			{
				DoubleDoublePair kv = prop.keyframes[i];

				if(kv.a <= time)
				{
					f64 a = kv.b;
					f64 b = prop.keyframes[i + 1].b;

					f64 t = (time - kv.a) / cast(f64)(prop.keyframes[i + 1].a - kv.a);

					string type = prop.functions[i + 1];
					if(type == "start")
					{
						properties[prop.name] = a;
						break;
					}

					properties[prop.name] = call(type, b - a, a, t);
				}
			}
		}
	}
	
	public static Animation load(int lengthInMs, string file)
	{
		assert(std.file.exists(file));
		return new Animation(lengthInMs, std.file.readText(file));
	}

	// Easing functions

	public static EasingFunction[string] easingFunctions;

	public static f64 call(string func, f64 delta, f64 offset, f64 time)
	{
		func = func.toLower();
		if((func in easingFunctions) is null)
		{
			Logger.errln("EasingFunction ", func, " is not defined!");
			return offset;
		}
		return easingFunctions[func](delta, offset, time);
	}

	static this()
	{
		string funcs[];
		
		foreach (member_string; __traits(allMembers, AnimationFunctions))
		{
			mixin("alias member = AnimationFunctions." ~ member_string ~ ";");
			static if (is(typeof(member) == function))
			{
				static if (__traits(isStaticFunction, member))
					easingFunctions[__traits(identifier, member)] = cast(EasingFunction)&member;
			}
		}
	}
}