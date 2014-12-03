module Enco.Shared.Random;

import EncoShared;
import std.datetime;

class Random
{
	this(u64 seed)
	{
		setSeed(seed);
	}

	this(u64 x, u64 y, u64 z)
	{
		m_x = x + 1; // Make sure they are not zero
		m_y = y + 1;
		m_z = z + 1;
	}

	this()
	{
		setSeed(Clock.currSystemTick().length);
	}

	void setSeed(u64 seed)
	{
		m_x = seed + 1; // Make sure they are not zero
		m_y = seed + 2;
		m_z = seed + 3;
	}

	void setSeed(u64 x, u64 y, u64 z)
	{
		m_x = x + 1; // Make sure they are not zero
		m_y = y + 1;
		m_z = z + 1;
	}

	u64 nextLong()
	{
		m_x ^= m_x << 16;
		m_x ^= m_x >> 5;
		m_x ^= m_x << 1;

		u64 t = m_x;
		m_x = m_y;
		m_y = m_z;
		m_z = t ^ m_x ^ m_y;

		return m_z;
	}

	u32 nextInt()
	{
		return nextLong() % u32.max;
	}

	u32 nextInt(u32 max)
	{
		return nextLong() % max;
	}

	f64 nextDouble()
	{
		return (nextLong() % u64.max) / cast(f64)u64.max;
	}

	f32 nextFloat()
	{
		return cast(f32)nextDouble();
	}

	bool nextBool()
	{
		return nextInt(2) == 0;
	}
	
	private u64 m_x = 56447;
	private u64 m_y = 48914;
	private u64 m_z = 84792;
}