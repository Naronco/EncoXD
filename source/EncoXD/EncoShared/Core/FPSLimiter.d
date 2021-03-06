module EncoShared.Core.FPSLimiter;

import core.thread;
import std.datetime;

/**
* Class for limiting your FPS.
* Examples:
* ---
* FPSLimiter limiter = new FPSLimiter(25);
* while(window.isOpen)
* {
*     // Draw and Update stuff
*     limiter.wait(); // Makes it 25 FPS
* }
* ---
*/
class FPSLimiter
{
protected:
	int	 _fps	 = 0;
	int	 _skipms = 0;
	long _next	 = 0;
	long _sleep	 = 0;

public:
	/// Creates a new FPS Limiter instance with specified max FPS.
	this(int maxFPS)
	{
		_fps	= maxFPS;
		_skipms = 1000 / _fps;
		_next	= Clock.currAppTick().to!("msecs", long);
	}

	/// Calculates how long to wait and then waits that amount of time to ensure the target FPS.
	void wait()
	{
		_next += _skipms;
		_sleep = _next - Clock.currAppTick().to!("msecs", long);
		if (_sleep > 0)
		{
			Thread.sleep(dur!("msecs")(_sleep));
		}
	}
}
