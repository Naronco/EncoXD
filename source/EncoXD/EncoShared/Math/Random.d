module EncoShared.Math.Random;

import EncoShared;
import std.datetime;

class Random
{
	public this(ulong seed)
	{
		setSeed(seed);
	}

	public this(ulong x, ulong y, ulong z)
	{
		m_x = x + 1; // Make sure they are not zero
		m_y = y + 1;
		m_z = z + 1;
	}

	public this()
	{
		setSeed(Clock.currSystemTick().length);
	}

	public void setSeed(ulong seed)
	{
		m_x = seed + 1; // Make sure they are not zero
		m_y = seed + 2;
		m_z = seed + 3;
	}

	public void setSeed(ulong x, ulong y, ulong z)
	{
		m_x = x + 1; // Make sure they are not zero
		m_y = y + 1;
		m_z = z + 1;
	}

	public ulong nextLong()
	{
		m_x ^= m_x << 16;
		m_x ^= m_x >> 5;
		m_x ^= m_x << 1;

		ulong t = m_x;
		m_x = m_y;
		m_y = m_z;
		m_z = t ^ m_x ^ m_y;

		return m_z;
	}

	public uint nextInt()
	{
		return nextLong() % uint.max;
	}

	public uint nextInt(uint max)
	{
		return nextLong() % max;
	}

	public double nextDouble()
	{
		return (nextLong() % ulong.max) / cast(double) ulong.max;
	}

	public float nextFloat()
	{
		return cast(float) nextDouble();
	}

	public bool nextBool()
	{
		return nextInt(2) == 0;
	}

	private ulong m_x = 56447;
	private ulong m_y = 48914;
	private ulong m_z = 84792;
}
