module Enco.Desktop.Input.Keyboard;

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
	public static void update() { state = new KeyboardState(keys.dup); }

	private static void setKey(u32 key, bool state)
	{
		if(state)
			keys[key] = true;
		else
			keys.remove(key);
	}

	private static KeyboardState* state;
	private static bool[int] keys;
}