module Enco.Shared.Animation.BasicEaseFunctions;

import EncoShared;

import std.math;

mixin template Linear()
{
	static f64 linear(f64 delta, f64 offset, f64 time)
	{
		return delta * time + offset;
	}
}

mixin template Quadratic()
{
	static f64 quadraticin(f64 delta, f64 offset, f64 time)
	{
		return delta * time * time + offset;
	}

	static f64 quadraticout(f64 delta, f64 offset, f64 time)
	{
		return -delta * time * (time - 2) + offset;
	}

	static f64 quadratic(f64 delta, f64 offset, f64 time)
	{
		time *= 2;
		if (time < 1) return delta * 0.5 * time * time + offset;
		time--;
		return -delta * 0.5 * (time * (time - 2) - 1) + offset;
	}
}

mixin template Cubic()
{
	static f64 cubicin(f64 delta, f64 offset, f64 time)
	{
		return delta * time * time * time + offset;
	}

	static f64 cubicout(f64 delta, f64 offset, f64 time)
	{
		time--;
		return delta * (time * time * time + 1) + offset;
	}

	static f64 cubic(f64 delta, f64 offset, f64 time)
	{
		time *= 2;
		if (time < 1) return delta * 0.5 * time * time * time + offset;
		time -= 2;
		return delta * 0.5 * (time * time * time + 2) + offset;
	}
}

mixin template Quartic()
{
	static f64 quarticin(f64 delta, f64 offset, f64 time)
	{
		return delta * time * time * time * time + offset;
	}

	static f64 quarticout(f64 delta, f64 offset, f64 time)
	{
		time--;
		return -delta * (time * time * time * time - 1) + offset;
	}

	static f64 quartic(f64 delta, f64 offset, f64 time)
	{
		time *= 2;
		if (time < 1) return delta * 0.5 * time * time * time * time + offset;
		time -= 2;
		return -delta * 0.5 * (time * time * time * time - 2) + offset;
	}
}


mixin template Quintic()
{
	static f64 quinticin(f64 delta, f64 offset, f64 time)
	{
		return delta * time * time * time * time * time + offset;
	}

	static f64 quinticout(f64 delta, f64 offset, f64 time)
	{
		time--;
		return delta * (time * time * time * time * time + 1) + offset;
	}

	static f64 quintic(f64 delta, f64 offset, f64 time)
	{
		time *= 2;
		if (time < 1) return delta * 0.5 * time * time * time * time * time + offset;
		time -= 2;
		return delta * 0.5 * (time * time * time * time * time + 2) + offset;
	}
}


mixin template Sinusoidal()
{
	static f64 sinusoidalin(f64 delta, f64 offset, f64 time)
	{
		return -delta * cos(time * (3.14159265359 * 0.5)) + delta + offset;
	}

	static f64 sinusoidalout(f64 delta, f64 offset, f64 time)
	{
		return delta * cos(time * (3.14159265359 * 0.5)) + offset;
	}

	static f64 sinusoidal(f64 delta, f64 offset, f64 time)
	{
		return -delta * 0.5 * (cos(3.14159265359 * time) - 1) + offset;
	}
}

mixin template Exponential()
{
	static f64 exponentialin(f64 delta, f64 offset, f64 time)
	{
		return delta * pow(2, 10 * (time - 1)) + offset;
	}

	static f64 exponentialout(f64 delta, f64 offset, f64 time)
	{
		return delta * (-pow(2, -10 * time) + 1) + offset;
	}

	static f64 exponential(f64 delta, f64 offset, f64 time)
	{
		time *= 2;
		if (time < 1) return delta * 0.5 * pow(2, 10 * (time - 1)) + offset;
		time--;
		return delta * 0.5 * (-pow(2, -10 * time) + 2) + offset;
	}
}

mixin template Circular()
{
	static f64 circularin(f64 delta, f64 offset, f64 time)
	{
		return -delta * (sqrt(1 - time * time) - 1) + offset;
	}

	static f64 circularout(f64 delta, f64 offset, f64 time)
	{
		time--;
		return delta * sqrt(1 - time * time) + offset;
	}

	static f64 circular(f64 delta, f64 offset, f64 time)
	{
		time *= 2;
		if (time < 1) return -delta * 0.5 * (sqrt(1 - time * time) - 1) + offset;
		time -= 2;
		return delta * 0.5 * (sqrt(1 - time * time) + 1) + offset;
	}
}

mixin template BasicEase()
{
	mixin Linear;
	mixin Quadratic;
	mixin Cubic;
	mixin Quartic;
	mixin Quintic;
	mixin Sinusoidal;
	mixin Exponential;
	mixin Circular;
}
