module Enco.Desktop.Input.Controller;

import EncoShared;
import EncoDesktop;

struct ControllerState
{
	public bool[] keys = new bool[SDL_CONTROLLER_BUTTON_MAX];
	public f64[] axis = new float[SDL_CONTROLLER_AXIS_MAX];
	public bool isConnected = false;

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
		if((index in states) == null)
			states[index] = ControllerState.init();
		return states[index];
	}

	public static void setKey(i32 index, u8 key, bool state)
	{
		if((index in states) is null)
			states[index] = ControllerState.init();
		states[index].keys[key] = state;
	}

	public static void setAxis(i32 index, u8 axis, i16 value)
	{
		if((index in states) is null)
			states[index] = ControllerState.init();
		states[index].axis[axis] = value * 0.00003051757; // 1 / 32768
	}

	public static void setConnected(i32 index, bool connected)
	{
		if((index in states) is null)
			states[index] = ControllerState.init();
		states[index].isConnected = connected;
	}

	public static ControllerState*[i32] states;
}