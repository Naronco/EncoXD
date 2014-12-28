module Player;

import EncoShared;
import EncoDesktop;

class Player : IComponent
{
	GameObject object;
	KeyboardState* state;

	void add(GameObject object)
	{
		this.object = object;
	}

	void preUpdate(f64 deltaTime)
	{
	}

	void update(f64 deltaTime)
	{
		state = Keyboard.getState();

		if(deltaTime == 0)
			Logger.warnln("Delta Time = 0!");

		vec3 off = vec3(0);

		if (state.isKeyDown(SDLK_w)) off += vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x));
		if (state.isKeyDown(SDLK_s)) off -= vec3(cos(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x), -sin(-object.transform.rotation.x), sin(-object.transform.rotation.y - 1.57079633f) * cos(-object.transform.rotation.x));
		if (state.isKeyDown(SDLK_a)) off -= vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y));
		if (state.isKeyDown(SDLK_d)) off += vec3(cos(-object.transform.rotation.y), 0, sin(-object.transform.rotation.y));
		if (state.isKeyDown(SDLK_SPACE)) off += vec3(0, 1, 0);
		if (state.isKeyDown(SDLK_LSHIFT)) off -= vec3(0, 1, 0);

		if(off.length_squared != 0)
			object.transform.position += off.normalized() * deltaTime * 10000;
	}

	void preDraw(RenderContext context, IRenderer renderer)
	{
	}

	void draw(RenderContext context, IRenderer renderer)
	{
	}
}