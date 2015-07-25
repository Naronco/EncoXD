module EncoShared.Core.TimeHelper;

import EncoShared;

import std.datetime;

class Timer
{
	public static long getMilliseconds()
	{
		return Clock.currStdTime() / 10000;
	}

	public static long getMicroseconds()
	{
		return Clock.currStdTime() / 10;
	}

	public static long getHectonanoseconds()
	{
		return Clock.currStdTime();
	}
}
