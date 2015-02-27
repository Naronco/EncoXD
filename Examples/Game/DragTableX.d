module DragTableX;

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
				startRotation = object.transform.rotation.y;
			}
			if(mstate.isButtonDown(0))
			{
				object.transform.rotation.y = startRotation + (startMousePos - mstate.position.x) * 0.004;
			}
			wasDown = mstate.isButtonDown(0);
		}
		if(cstate.isConnected) object.transform.rotation -= vec3(0, cstate.getAxis(2), 0) * deltaTime * 2;
		mstate = Mouse.getState();
	}
	
	private bool wasDown = false;
	private float startMousePos = 0;
	private float startRotation = 0;
	private MouseState* mstate;
	private ControllerState* cstate;
	public GameObject object;
}