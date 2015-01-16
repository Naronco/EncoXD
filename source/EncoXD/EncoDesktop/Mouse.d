module Enco.Desktop.Input.Mouse;

import EncoShared;
import EncoDesktop;

struct MouseState
{
	public vec2 position;
	public vec2 offset;
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

	public static void update()
	{
		state = new MouseState();
		state.position = position;
		state.offset = offset;
		state.buttons[] = buttons;
	}

	public static void setButton(i8 button, bool isDown)
	{
		buttons[button - 1] = isDown;
	}

	public static void setPosition(i32 x, i32 y)
	{
		position.x = x;
		position.y = y;
	}

	public static void addOffset(i32 x, i32 y)
	{
		offset.x += x;
		offset.y += y;
	}

	public static void setOffset(i32 x, i32 y)
	{
		offset.x = x;
		offset.y = y;
	}
	
	public static MouseState* state;
	public static vec2 position = vec2(0, 0);
	public static vec2 offset = vec2(0, 0);
	public static bool[] buttons = new bool[8];
}