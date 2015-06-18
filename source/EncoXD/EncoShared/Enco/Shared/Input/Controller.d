module Enco.Shared.Input.Controller;

import EncoShared;

struct ControllerState
{
	public						 bool[] keys = new bool[SDL_CONTROLLER_BUTTON_MAX];
	public						 f64[] axis = new float[SDL_CONTROLLER_AXIS_MAX];
	public bool					 isConnected = false;

	public static ControllerState* init()
	{
		ControllerState* state = new ControllerState();
		state.axis[] = 0;
		state.keys[] = false;
		return state;
	}

	public bool isKeyDown(u8 key)
	{
		return keys[key];
	}

	public bool isKeyUp(u8 key)
	{
		return !keys[key];
	}

	public f64 getAxis(i8 index)
	{
		return axis[index];
	}
}

class Controller
{
	public static ControllerState* getState(i32 index)
	{
		if ((index in states) == null)
			states[index] = ControllerState.init();
		return states[index];
	}

	public static void setKey(i32 index, u8 key, bool state)
	{
		if ((index in states) is null)
			states[index] = ControllerState.init();
		states[index].keys[key] = state;
	}

	public static void setAxis(i32 index, u8 axis, i16 value)
	{
		if ((index in states) is null)
			states[index] = ControllerState.init();
		states[index].axis[axis] = value * 0.00003051757; // 1 / 32768
	}

	public static void setConnected(i32 index, bool connected)
	{
		if ((index in states) is null)
			states[index] = ControllerState.init();
		states[index].isConnected = connected;
	}

	public static ControllerState*[i32] states;
}

enum ControllerIndex : i32
{
	One = 0,
	Two,
	Three,
	Four
}

enum ControllerAxis : u8
{
	Invalid = 255,
	LeftX	= 0,
	LeftY,
	RightX,
	RightY,
	TriggerLeft,
	TriggerRight
}

struct ControllerAxisEvent
{
	u32 timestamp;
	union
	{
		ControllerIndex index;
		i32				id;
	}
	union
	{
		ControllerAxis axis;
		u8			   axisID;
	}
	i16 value;
}

enum ControllerButton : u8
{
	Invalid = 255,
	A		= 0,
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
	u32 timestamp;
	union
	{
		ControllerIndex index;
		i32				id;
	}
	union
	{
		ControllerButton button;
		u8				 buttonID;
	}
	u8 state;
}

struct ControllerButtonUpEvent
{
	u32 timestamp;
	union
	{
		ControllerIndex index;
		i32				id;
	}
	union
	{
		ControllerButton button;
		u8				 buttonID;
	}
	u8 state;
}

struct ControllerAddedEvent
{
	u32 timestamp;
	union
	{
		ControllerIndex index;
		i32				id;
	}
}

struct ControllerRemovedEvent
{
	u32 timestamp;
	union
	{
		ControllerIndex index;
		i32				id;
	}
}
