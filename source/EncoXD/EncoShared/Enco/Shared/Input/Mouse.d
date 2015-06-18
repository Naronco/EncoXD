module Enco.Shared.Input.Mouse;

import EncoShared;

struct MouseState
{
	public vec2 position = vec2(0, 0);
	public vec2 offset = vec2(0, 0);
	public bool[] buttons = new bool[8];

	public bool isButtonDown(u8 button)
	{
		return buttons[button];
	}

	public bool isButtonUp(u8 button)
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

	public static void setButton(i8 button, bool isDown)
	{
		state.buttons[button - 1] = isDown;
	}

	public static void setPosition(i32 x, i32 y)
	{
		state.position.x = x;
		state.position.y = y;
	}

	public static void addOffset(i32 x, i32 y)
	{
		state.offset.x += x;
		state.offset.y += y;
	}

	public static void setOffset(i32 x, i32 y)
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
	u32 id;
	u32 windowID;
	u32 timestamp;
	i32vec2 position;
	i32vec2 offset;
}

enum MouseButton : u8
{
	Left,
	Middle,
	Right,
	X1,
	X2
}

struct MouseButtonDownEvent
{
	u32 id;
	u32 windowID;
	u32 timestamp;
	i32vec2 position;
	union
	{
		u8 buttonID;
		MouseButton button;
	}
	u8 clicks;
	u8 state;
}

struct MouseButtonUpEvent
{
	u32 id;
	u32 windowID;
	u32 timestamp;
	i32vec2 position;
	union
	{
		u8 buttonID;
		MouseButton button;
	}
	u8 clicks;
	u8 state;
}

struct MouseWheelEvent
{
	u32 timestamp;
	u32 windowID;
	u32 id;
	i32vec2 amount;
	bool flipped;
}