module Player;

import EncoShared;
import EncoDesktop;

class Player : IComponent
{
	GameObject object;
	KeyboardState  * state;
	ControllerState* controller;

	override void add(GameObject object)
	{
		this.object = object;
	}

	override void preUpdate(double deltaTime)
	{
	}

	override void update(double deltaTime)
	{
		state = Keyboard.getState();
		controller = Controller.getState(0);

		vec3 off = vec3(0);

		if (state.isKeyDown(SDLK_w))
			off += vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x));
		if (controller.isConnected && abs(controller.getAxis(1)) > 0.3)
			off += vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x)) * -controller.getAxis(1);
		if (state.isKeyDown(SDLK_s))
			off -= vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x));
		if (state.isKeyDown(SDLK_a))
			off -= vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y));
		if (state.isKeyDown(SDLK_d))
			off += vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y));
		if (controller.isConnected && abs(controller.getAxis(0)) > 0.3)
			off += vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y)) * controller.getAxis(0);
		if (state.isKeyDown(SDLK_SPACE))
			off += vec3(0, 1, 0);
		if (state.isKeyDown(SDLK_LSHIFT))
			off -= vec3(0, 1, 0);
		if (controller.isConnected && controller.isKeyDown(SDL_CONTROLLER_BUTTON_A))
			off += vec3(0, 1, 0);
		if (controller.isConnected && controller.isKeyDown(SDL_CONTROLLER_BUTTON_B))
			off -= vec3(0, 1, 0);

		if (off.length_squared != 0)
			object.transform.position += off.normalized() * deltaTime * 10;
	}

	override void preDraw(RenderContext context, IRenderer renderer)
	{
	}

	override void draw(RenderContext context, IRenderer renderer)
	{
	}
}
