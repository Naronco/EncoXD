module EncoShared.Core.Event;

import EncoShared;

class Event(T ...)
{
	alias EventMethod = void delegate(Object, T);
	private EventMethod[] funcs;

	public this()
	{
	}

	public void opOpAssign(string op)(const EventMethod func) if (op == "+")
	{
		if (!funcs.contains(func))
			funcs ~= func;
	}

	public void opOpAssign(string op)(const EventMethod func) if (op == "-")
	{
		if (funcs.contains(func))
		{
			EventMethod[] newFuncs;
			foreach (EventMethod method; funcs)
			{
				if (func != method)
					newFuncs ~= method;
			}
			funcs[] = null;
			funcs = newFuncs;
		}
	}

	void opCall(Object sender, T args)
	{
		foreach (ref func; funcs)
			func(sender, args);
	}
}

/// Event without arguments
class Trigger
{
	alias EventMethod = void delegate(Object);
	private EventMethod[] funcs;

	public this()
	{
	}

	public void opOpAssign(string op)(const EventMethod func) if (op == "+")
	{
		if (!funcs.contains(func))
			funcs ~= func;
	}

	public void opOpAssign(string op)(const EventMethod func) if (op == "-")
	{
		if (funcs.contains(func))
		{
			EventMethod[] newFuncs;
			foreach (EventMethod method; funcs)
			{
				if (func != method)
					newFuncs ~= method;
			}
			funcs[] = null;
			funcs = newFuncs;
		}
	}

	void opCall(Object sender)
	{
		foreach (ref func; funcs)
			func(sender);
	}
}
