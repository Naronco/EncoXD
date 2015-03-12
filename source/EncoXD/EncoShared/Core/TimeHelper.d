module Enco.Shared.Core.TimeHelper;

import EncoShared;

import std.datetime;

class Timer
{
	public static i64 getMilliseconds() { return Clock.currStdTime() / 10000; }

	public static i64 getMicroseconds() { return Clock.currStdTime() / 10; }

	public static i64 getHectonanoseconds() { return Clock.currStdTime(); }
}
