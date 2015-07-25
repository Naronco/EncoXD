module EncoShared.Input.Mouse;

import EncoShared;

struct MouseState
{
	public vec2 position = vec2(0, 0);
	public vec2 offset = vec2(0, 0);
	public bool[] buttons = new bool[8];

	public bool isButtonDown(ubyte button)
	{
		return buttons[button];
	}

	public bool isButtonUp(ubyte button)
	{
		return !buttons[button];
	}
}

class Mouse
{
	public static MouseState* getState()
	{
		return state;
	}

	public static void capture()
	{
		SDL_SetRelativeMouseMode(true);
		SDL_ShowCursor(false);
	}

	public static void release()
	{
		SDL_SetRelativeMouseMode(false);
		SDL_ShowCursor(true);
	}

	public static void setButton(byte button, bool isDown)
	{
		state.buttons[button - 1] = isDown;
	}

	public static void setPosition(int x, int y)
	{
		state.position.x = x;
		state.position.y = y;
	}

	public static void addOffset(int x, int y)
	{
		state.offset.x += x;
		state.offset.y += y;
	}

	public static void setOffset(int x, int y)
	{
		state.offset.x = x;
		state.offset.y = y;
	}

	public static MouseState* state;

	static this()
	{
		state = new MouseState();
	}
}

struct MouseMoveEvent
{
	uint id;
	uint windowID;
	uint timestamp;
	i32vec2 position;
	i32vec2 offset;
}

enum MouseButton : ubyte
{
	Left,
	Middle,
	Right,
	X1,
	X2
}

struct MouseButtonDownEvent
{
	uint id;
	uint windowID;
	uint timestamp;
	i32vec2 position;
	union
	{
		ubyte buttonID;
		MouseButton button;
	}
	ubyte clicks;
	ubyte state;
}

struct MouseButtonUpEvent
{
	uint id;
	uint windowID;
	uint timestamp;
	i32vec2 position;
	union
	{
		ubyte buttonID;
		MouseButton button;
	}
	ubyte clicks;
	ubyte state;
}

struct MouseWheelEvent
{
	uint timestamp;
	uint windowID;
	uint id;
	i32vec2 amount;
	bool flipped;
}
