module Enco.Desktop.Input.Controller;

import EncoShared;
import EncoDesktop;

struct ControllerState
{
	public bool[] keys = new bool[SDL_CONTROLLER_BUTTON_MAX];
	public f32[] axis = new float[SDL_CONTROLLER_AXIS_MAX];
	
	public bool isKeyDown(u8 key)
	{
		return keys[key];
	}

	public bool isKeyUp(u8 key)
	{
		return !keys[key];
	}
}

class Controller
{
	public static ControllerState* getState(u8 index) { return states[index]; }

	public static void setKey(u8 index, u8 key, bool state)
	{
		states[index].keys[key] = state;
	}

	public static void setAxis(u8 index, u8 axis, i16 value)
	{
		states[index].axis[axis] = value * 0.0000305185; // 1 / 32767
	}

	public static ControllerState*[4] states;

	static this()
	{
		states = [new ControllerState(), new ControllerState(), new ControllerState(), new ControllerState()];
	}
}