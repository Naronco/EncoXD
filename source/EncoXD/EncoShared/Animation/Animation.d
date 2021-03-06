module EncoShared.Animation.Animation;

import EncoShared;

class AnimationFunctions
{
	mixin BasicEase;
}

struct DoubleDoublePair
{
	public double a;
	public double b;

	public string toString()
	{
		return format("%g;%g", a, b);
	}
}

struct AnimatedAnimationProperty
{
	public string name;
	public string[] functions;
	public DoubleDoublePair[] keyframes;

	public string toString()
	{
		return format("%s = %s -> %s", name, functions, keyframes);
	}

	public @property AnimatedAnimationProperty dup()
	{
		AnimatedAnimationProperty b;
		b.name = name;
		b.functions = functions.dup;
		b.keyframes = keyframes.dup;
		return b;
	}
}

alias EasingFunction = double function(double, double, double);

class Animation
{
	private double currentTime = 0;
	private double iLengthInSec = 0;
	private AnimatedAnimationProperty[] props;

	public double[string] properties;
	public double time = 0;
	private bool m_done = false;
	public @property bool done()
	{
		return m_done;
	}

	public Trigger onDone = new Trigger();

	public this(int ms, string storyboard)
	{
		string[] lines = storyboard.split('\n');
		iLengthInSec = 1 / (ms * 0.001);

		AnimatedAnimationProperty current = AnimatedAnimationProperty();
		current.name = null;

		bool cmp(DoubleDoublePair x, DoubleDoublePair y) @safe nothrow
		{
			return x.a < y.a;
		}

		foreach (int i, string line; lines)
		{
			line = line.trim();

			if (line.length == 0)
				continue;
			if (line[0] == '#')
				continue;
			if (line[0] == '!')
			{
				if (current.name !is null)
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
				double t, val;

				t = to!double(splits[1].trim());
				val = to!double(splits[2].trim());

				current.keyframes ~= DoubleDoublePair(t, val);
			}
		}

		if (current.name !is null)
		{
			assert(current.keyframes.length > 1, "At least 2 keyframes needed!");
			sort!(cmp)(current.keyframes);
			props ~= current.dup;
		}

		foreach (prop; props)
			properties[prop.name] = 0;
	}

	public double get(string name)
	{
		if ((name in properties) !is null)
			return properties[name];
		return 0;
	}

	public void update(double delta)
	{
		if (!m_done)
		{
			currentTime += delta;
			time = currentTime * iLengthInSec;

			if (time > 1)
			{
				time = 1;
				m_done = true;
			}

			foreach (prop; props)
			{
				for (uint i = cast(uint) prop.keyframes.length - 2; i >= 0; i--)
				{
					DoubleDoublePair kv = prop.keyframes[i];

					if (kv.a <= time)
					{
						double a = kv.b;
						double b = prop.keyframes[i + 1].b;

						double t = (time - kv.a) / cast(double) (prop.keyframes[i + 1].a - kv.a);

						string type = prop.functions[i + 1];
						if (type == "start")
						{
							properties[prop.name] = a;
							break;
						}

						properties[prop.name] = call(type, b - a, a, t);
					}
				}
			}
			if (m_done)
			{
				onDone(this);
			}
		}
	}

	public static Animation load(int lengthInMs, string file)
	{
		assert(std.file.exists(file));
		return new Animation(lengthInMs, std.file.readText(file));
	}

	// Easing functions

	public static const EasingFunction[string] easingFunctions;

	public static double call(string func, double delta, double offset, double time)
	{
		func = func.toLower();
		if ((func in easingFunctions) is null)
		{
			Logger.errln("EasingFunction ", func, " is not defined!");
			return offset;
		}
		return easingFunctions[func](delta, offset, time);
	}

	static this()
	{
		string[] funcs;

		foreach (member_string; __traits (allMembers, AnimationFunctions))
		{
			mixin("alias member = AnimationFunctions." ~ member_string ~ ";");
			static if (is (typeof(member) == function))
			{
				static if (__traits (isStaticFunction, member))
					easingFunctions[__traits (identifier, member)] = cast(EasingFunction) &member;
			}
		}
	}
}
