module Enco.Shared.Components.FreeMove;

import EncoShared;

class FreeMove : IComponent
{
	public override void add(GameObject object)
	{
		this.object = object;
	}

	public override void draw(RenderContext context, IRenderer renderer)
	{
	}

	public override void preDraw(RenderContext context, IRenderer renderer)
	{
	}

	public override void preUpdate(f64 deltaTime)
	{
	}

	public override void update(f64 deltaTime)
	{
		kstate = Keyboard.getState();
		cstate = Controller.getState(0);

		vec3 off = vec3(0);

		if (kstate.isKeyDown(SDLK_w))
			off += vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x));
		if (cstate.isConnected && abs(cstate.getAxis(1)) > 0.3)
			off += vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x)) * -cstate.getAxis(1);
		if (kstate.isKeyDown(SDLK_s))
			off -= vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x));
		if (kstate.isKeyDown(SDLK_a))
			off -= vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y));
		if (kstate.isKeyDown(SDLK_d))
			off += vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y));
		if (cstate.isConnected && abs(cstate.getAxis(0)) > 0.3)
			off += vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y)) * cstate.getAxis(0);
		if (kstate.isKeyDown(SDLK_SPACE))
			off += vec3(0, 1, 0);
		if (kstate.isKeyDown(SDLK_LSHIFT))
			off -= vec3(0, 1, 0);
		if (cstate.isConnected && cstate.isKeyDown(SDL_CONTROLLER_BUTTON_A))
			off += vec3(0, 1, 0);
		if (cstate.isConnected && cstate.isKeyDown(SDL_CONTROLLER_BUTTON_B))
			off -= vec3(0, 1, 0);

		if (off.length_squared != 0)
			object.transform.position += off.normalized() * deltaTime * 10;
	}

	private KeyboardState  * kstate;
	private ControllerState* cstate;
	public GameObject	   object;
}
