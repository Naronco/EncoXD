module Enco.Shared.Components.FPSRotation;

import EncoShared;

class FPSRotation : IComponent
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
		mstate = Mouse.getState();
		cstate = Controller.getState(0);
		object.transform.rotation -= vec3(mstate.offset.y, mstate.offset.x, 0) * deltaTime * 0.5;
		if (cstate.isConnected)
			object.transform.rotation -= vec3(cstate.getAxis(3), cstate.getAxis(2), 0) * deltaTime * 2;
		if (object.transform.rotation.x > 1.5707963f)
			object.transform.rotation.x = 1.5707963f;
		if (object.transform.rotation.x < -1.5707963f)
			object.transform.rotation.x = -1.5707963f;
	}

	private MouseState     * mstate;
	private ControllerState* cstate;
	public GameObject object;
}
