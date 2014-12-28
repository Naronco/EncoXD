module Enco.Desktop.FPSRotation;

import EncoShared;
import EncoDesktop;

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
		object.transform.rotation -= vec3(mstate.offset.y, mstate.offset.x, 0) * 0.005f;
		if(object.transform.rotation.x > 1.57079633f) object.transform.rotation.x = 1.57079633f;
		if(object.transform.rotation.x < -1.57079633f) object.transform.rotation.x = -1.57079633f;
	}
	
	public MouseState* mstate;
	public GameObject object;
}