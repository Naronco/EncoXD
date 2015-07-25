module EncoShared.Input.Controller;

import EncoShared;

struct ControllerState
{
	public bool[] keys = new bool[SDL_CONTROLLER_BUTTON_MAX];
	public double[] axis = new float[SDL_CONTROLLER_AXIS_MAX];
	public bool isConnected = false;

	public static ControllerState* init()
	{
		ControllerState* state = new ControllerState();
		state.axis[] = 0;
		state.keys[] = false;
		return state;
	}

	public bool isKeyDown(ubyte key)
	{
		return keys[key];
	}

	public bool isKeyUp(ubyte key)
	{
		return !keys[key];
	}

	public double getAxis(byte index)
	{
		return axis[index];
	}
}

class Controller
{
	public static ControllerState* getState(int index)
	{
		if ((index in states) == null)
			states[index] = ControllerState.init();
		return states[index];
	}

	public static void setKey(int index, ubyte key, bool state)
	{
		if ((index in states) is null)
			states[index] = ControllerState.init();
		states[index].keys[key] = state;
	}

	public static void setAxis(int index, ubyte axis, short value)
	{
		if ((index in states) is null)
			states[index] = ControllerState.init();
		states[index].axis[axis] = value * 0.00003051757; // 1 / 32768
	}

	public static void setConnected(int index, bool connected)
	{
		if ((index in states) is null)
			states[index] = ControllerState.init();
		states[index].isConnected = connected;
	}

	public static ControllerState*[int] states;
}

enum ControllerIndex : int
{
	One = 0,
	Two,
	Three,
	Four
}

enum ControllerAxis : ubyte
{
	Invalid = 255,
	LeftX   = 0,
	LeftY,
	RightX,
	RightY,
	TriggerLeft,
	TriggerRight
}

struct ControllerAxisEvent
{
	uint timestamp;
	union
	{
		ControllerIndex index;
		int id;
	}
	union
	{
		ControllerAxis axis;
		ubyte axisID;
	}
	short value;
}

enum ControllerButton : ubyte
{
	Invalid = 255,
	A       = 0,
	B,
	X,
	Y,
	Back,
	Select,
	Start,
	LeftStick,
	RightStick,
	LeftShoulder,
	RightShoulder,
	DPadUp,
	DPadDown,
	DPadLeft,
	DPadRight
}

struct ControllerButtonDownEvent
{
	uint timestamp;
	union
	{
		ControllerIndex index;
		int id;
	}
	union
	{
		ControllerButton button;
		ubyte buttonID;
	}
	ubyte state;
}

struct ControllerButtonUpEvent
{
	uint timestamp;
	union
	{
		ControllerIndex index;
		int id;
	}
	union
	{
		ControllerButton button;
		ubyte buttonID;
	}
	ubyte state;
}

struct ControllerAddedEvent
{
	uint timestamp;
	union
	{
		ControllerIndex index;
		int id;
	}
}

struct ControllerRemovedEvent
{
	uint timestamp;
	union
	{
		ControllerIndex index;
		int id;
	}
}
