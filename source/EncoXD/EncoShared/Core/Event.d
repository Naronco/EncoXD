module Enco.Shared.Core.Event;

import EncoShared;

class Event(T)
{
	alias EventMethod = void delegate(Object, T);
	private EventMethod[] funcs;

	public this()
	{
	}

	public void opOpAssign(string op)(EventMethod func) if (op == "+")
	{
		if(!funcs.contains(func))
			funcs ~= func;
	}

	public void opOpAssign(string op)(EventMethod func) if (op == "-")
	{
		if(funcs.contains(func))
		{
			EventMethod[] newFuncs;
			foreach(EventMethod method; funcs)
			{
				if(func != method)
					newFuncs ~= method;
			}
			funcs = newFuncs;
		}
	}

	void opCall(Object sender, T args)
	{
		foreach(ref func; funcs)
			func(sender, args);
	}
}