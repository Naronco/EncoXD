module Enco.Shared.Animation.BasicEaseFunctions;

import EncoShared;

import std.math;

mixin template Linear()
{
	static double linear(double delta, double offset, double time)
	{
		return delta * time + offset;
	}
}

mixin template Quadratic()
{
	static double quadraticin(double delta, double offset, double time)
	{
		return delta * time * time + offset;
	}

	static double quadraticout(double delta, double offset, double time)
	{
		return -delta * time * (time - 2) + offset;
	}

	static double quadratic(double delta, double offset, double time)
	{
		time *= 2;
		if (time < 1)
			return delta * 0.5 * time * time + offset;
		time--;
		return -delta * 0.5 * (time * (time - 2) - 1) + offset;
	}
}

mixin template Cubic()
{
	static double cubicin(double delta, double offset, double time)
	{
		return delta * time * time * time + offset;
	}

	static double cubicout(double delta, double offset, double time)
	{
		time--;
		return delta * (time * time * time + 1) + offset;
	}

	static double cubic(double delta, double offset, double time)
	{
		time *= 2;
		if (time < 1)
			return delta * 0.5 * time * time * time + offset;
		time -= 2;
		return delta * 0.5 * (time * time * time + 2) + offset;
	}
}

mixin template Quartic()
{
	static double quarticin(double delta, double offset, double time)
	{
		return delta * time * time * time * time + offset;
	}

	static double quarticout(double delta, double offset, double time)
	{
		time--;
		return -delta * (time * time * time * time - 1) + offset;
	}

	static double quartic(double delta, double offset, double time)
	{
		time *= 2;
		if (time < 1)
			return delta * 0.5 * time * time * time * time + offset;
		time -= 2;
		return -delta * 0.5 * (time * time * time * time - 2) + offset;
	}
}


mixin template Quintic()
{
	static double quinticin(double delta, double offset, double time)
	{
		return delta * time * time * time * time * time + offset;
	}

	static double quinticout(double delta, double offset, double time)
	{
		time--;
		return delta * (time * time * time * time * time + 1) + offset;
	}

	static double quintic(double delta, double offset, double time)
	{
		time *= 2;
		if (time < 1)
			return delta * 0.5 * time * time * time * time * time + offset;
		time -= 2;
		return delta * 0.5 * (time * time * time * time * time + 2) + offset;
	}
}


mixin template Sinusoidal()
{
	static double sinusoidalin(double delta, double offset, double time)
	{
		return -delta * cos(time * (3.14159265359 * 0.5)) + delta + offset;
	}

	static double sinusoidalout(double delta, double offset, double time)
	{
		return delta * cos(time * (3.14159265359 * 0.5)) + offset;
	}

	static double sinusoidal(double delta, double offset, double time)
	{
		return -delta * 0.5 * (cos(3.14159265359 * time) - 1) + offset;
	}
}

mixin template Exponential()
{
	static double exponentialin(double delta, double offset, double time)
	{
		return delta * pow(2, 10 * (time - 1)) + offset;
	}

	static double exponentialout(double delta, double offset, double time)
	{
		return delta * (-pow(2, -10 * time) + 1) + offset;
	}

	static double exponential(double delta, double offset, double time)
	{
		time *= 2;
		if (time < 1)
			return delta * 0.5 * pow(2, 10 * (time - 1)) + offset;
		time--;
		return delta * 0.5 * (-pow(2, -10 * time) + 2) + offset;
	}
}

mixin template Circular()
{
	static double circularin(double delta, double offset, double time)
	{
		return -delta * (sqrt(1 - time * time) - 1) + offset;
	}

	static double circularout(double delta, double offset, double time)
	{
		time--;
		return delta * sqrt(1 - time * time) + offset;
	}

	static double circular(double delta, double offset, double time)
	{
		time *= 2;
		if (time < 1)
			return -delta * 0.5 * (sqrt(1 - time * time) - 1) + offset;
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
