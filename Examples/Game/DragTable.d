module DragTable;

import EncoShared;
import EncoDesktop;

class DragTableX : IComponent
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
		cstate = Controller.getState(0);
		if(mstate !is null)
		{
			if(!wasDown && mstate.isButtonDown(0))
			{
				startMousePos = mstate.position.x;
				startRotation = object.transform.rotation.pitch;
			}
			if(mstate.isButtonDown(0))
			{
				object.transform.rotation = object.transform.rotation.euler_rotation(object.transform.rotation.yaw, startRotation + (startMousePos - mstate.position.x) * 0.004, object.transform.rotation.roll);
			}
			wasDown = mstate.isButtonDown(0);
		}
		if(cstate.isConnected) object.transform.rotation = object.transform.rotation.euler_rotation(object.transform.rotation.yaw, object.transform.rotation.pitch - cstate.getAxis(2) * deltaTime * 2, object.transform.rotation.roll);
		mstate = Mouse.getState();
	}

	private bool wasDown = false;
	private float startMousePos = 0;
	private float startRotation = 0;
	private MouseState* mstate;
	private ControllerState* cstate;
	public GameObject object;
}

class DragTableHalfY : IComponent
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
		cstate = Controller.getState(0);
		if(mstate !is null)
		{
			if(!wasDown && mstate.isButtonDown(0))
			{
				startMousePos = mstate.position.y;
				startRotation = object.transform.rotation.yaw;
			}
			if(mstate.isButtonDown(0))
			{
				object.transform.rotation = object.transform.rotation.euler_rotation(startRotation + (startMousePos - mstate.position.y) * 0.004, object.transform.rotation.pitch, object.transform.rotation.roll);
			}
			wasDown = mstate.isButtonDown(0);
		}
		if(cstate.isConnected) object.transform.rotation = object.transform.rotation.euler_rotation(object.transform.rotation.yaw - cstate.getAxis(3) * deltaTime * 2, object.transform.rotation.pitch, object.transform.rotation.roll);
		if(object.transform.rotation.yaw > -0.4f) object.transform.rotation = object.transform.rotation.euler_rotation(-0.4f, object.transform.rotation.pitch, object.transform.rotation.roll);
		if(object.transform.rotation.yaw < -1.57f) object.transform.rotation.rotate_euler(-1.57f, object.transform.rotation.pitch, object.transform.rotation.roll);
		mstate = Mouse.getState();
	}

	private bool wasDown = false;
	private float startMousePos = 0;
	private float startRotation = 0;
	private MouseState* mstate;
	private ControllerState* cstate;
	public GameObject object;
}
