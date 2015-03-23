module Enco.Shared.Components.FPSRotation;

import EncoShared;

class FPSRotation : IComponent
{
	public override void add(GameObject object)
	{
		this.object = object;
	}

	public override void draw(RenderContext context, IRenderer renderer) {
	}

	public override void preDraw(RenderContext context, IRenderer renderer) {
	}

	public override void preUpdate(f64 deltaTime) {
	}

	public override void update(f64 deltaTime)
	{
		mstate = Mouse.getState();
		cstate = Controller.getState(0);
		object.transform.rotation = object.transform.rotation.euler_rotation(-mstate.offset.x * deltaTime * 0.5, 0, -mstate.offset.y * deltaTime * 0.5) * object.transform.rotation;
		//if(cstate.isConnected) object.transform.rotation = object.transform.rotation.euler_rotation(object.transform.rotation.yaw - cstate.getAxis(3) * deltaTime * 2, object.transform.rotation.pitch - cstate.getAxis(2) * deltaTime * 2, object.transform.rotation.roll);
		//if(object.transform.rotation.yaw > 1.5707963f) object.transform.rotation = object.transform.rotation.euler_rotation(1.5707963f, object.transform.rotation.pitch, object.transform.rotation.roll);
		//if(object.transform.rotation.yaw < -1.5707963f) object.transform.rotation = object.transform.rotation.euler_rotation(-1.5707963f, object.transform.rotation.pitch, object.transform.rotation.roll);
	}

	private MouseState* mstate;
	private ControllerState* cstate;
	public GameObject object;
}
