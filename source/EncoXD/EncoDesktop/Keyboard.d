module Enco.Desktop.Input.Keyboard;

import EncoShared;
import EncoDesktop;

struct KeyboardState
{
	public bool[int] keys;
	
	public bool isKeyDown(u32 key)
	{
		return (key in keys) !is null;
	}

	public bool isKeyUp(u32 key)
	{
		return (key in keys) is null;
	}
}

class Keyboard
{
	public static KeyboardState* getState() { return state; }

	public static void setKey(u32 key, bool click)
	{
		if(click)
			state.keys[key] = true;
		else
			state.keys.remove(key);
	}

	public static KeyboardState* state;

	static this()
	{
		state = new KeyboardState();
	}
}