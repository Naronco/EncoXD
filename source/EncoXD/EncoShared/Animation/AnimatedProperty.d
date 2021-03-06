module EncoShared.Animation.AnimatedProperty;

import EncoShared;

enum AnimationState
{
	Animating,
	Still
}

/// Animation handler for a numeric type
class AnimatedProperty(T)
{
	private T intVal = 0;
	private T finishVal = 0;
	private double time = 0;
	private double iTimeSec = 1;
	private AnimationState state = AnimationState.Still;
	private string easeType = "linear";

	public Trigger onDone = new Trigger();

	public this()
	{
	}

	public this(T val)
	{
		intVal = val;
	}

	public @property T value()
	{
		if (state == AnimationState.Still)
			return intVal;
		return cast(T) Animation.call(easeType, cast(double) (finishVal - intVal), cast(double) intVal, min(1, max(0, time)));
	}

	public @property void value(T val)
	{
		if (finishVal == val)
			return;
		intVal = value;
		finishVal = val;
		state = AnimationState.Animating;
		time = 0;
	}

	/// Current animation state
	public @property AnimationState animationState()
	{
		return state;
	}

	/// Easing function from Animation.easingFunctions
	public @property string easingType()
	{
		return easeType;
	}
	/// ditto
	public @property void easingType(string val)
	{
		assert((val.trim().toLower() in Animation.easingFunctions) !is null);
		easeType = val.trim().toLower();
	}

	/// Length in milliseconds
	public @property int length()
	{
		return cast(int) round(1000.0 / iTimeSec);
	}
	/// ditto
	public @property void length(int ms)
	{
		iTimeSec = 1000.0 / ms;
	}

	/// Update
	/// Params:
	///		delta = Delta time in seconds
	public void update(double delta)
	{
		if (state == AnimationState.Animating)
		{
			time += delta * iTimeSec;
			if (time >= 1)
			{
				intVal = finishVal;
				state = AnimationState.Still;
				onDone(this);
			}
		}
	}


	public override int opUnary(string s)()
	{
		return intVal.opUnary!(s)();
	}

	public U opCast(U)()
	{
		return cast(U) value;
	}

	public U opBinary(string op)(Object b)
	{
		return intVal.opBinary!(op)(b);
	}
}


/// Animated Property with custom functions and support for more types than numerics
class AnimatedFunctionValue(T)
{
	T function(T, T, double) interpolationFunction = (T delta, T start, double time)
	{
		return start + delta * time;
	};

	private T intVal = 0;
	private T finishVal = 0;
	private double time = 0;
	private double iTimeSec = 1;
	private AnimationState state = AnimationState.Still;

	public Trigger onDone = new Trigger();

	public this()
	{
	}

	public this(T val)
	{
		intVal = val;
	}

	public @property T value()
	{
		if (state == AnimationState.Still)
			return intVal;
		return interpolationFunction(finishVal - intVal, intVal, min(1, max(0, time)));
	}

	public @property void value(T val)
	{
		if (finishVal == val)
			return;
		intVal = value;
		finishVal = val;
		state = AnimationState.Animating;
		time = 0;
	}

	/// Current animation state
	public @property AnimationState animationState()
	{
		return state;
	}

	/// Length in milliseconds
	public @property int length()
	{
		return cast(int) round(1000.0 / iTimeSec);
	}
	/// ditto
	public @property void length(int ms)
	{
		iTimeSec = 1000.0 / ms;
	}

	/// Update
	/// Params:
	///		delta = Delta time in seconds
	public void update(double delta)
	{
		if (state == AnimationState.Animating)
		{
			time += delta * iTimeSec;
			if (time >= 1)
			{
				intVal = finishVal;
				state = AnimationState.Still;
				onDone(this);
			}
		}
	}


	public override int opUnary(string s)()
	{
		return intVal.opUnary!(s)();
	}

	public U opCast(U)()
	{
		return cast(U) value;
	}

	public U opBinary(string op)(Object b)
	{
		return intVal.opBinary!(op)(b);
	}
}
