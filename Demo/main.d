import EncoShared;
import EncoDesktop;
import EncoGL3;

import GameScene;

import std.stdio;
import std.traits;

void main() {
	auto renderer = new GL3Renderer();
	auto context = new EncoContext(
				new DesktopView("UTF-8 Magic *:･ﾟ✧ (∩ ͡° ͜ʖ ͡°)⊃━☆ﾟ. * ･", 1600, 900),
				renderer,
				new GameScene());
	context.start();
	renderer.setClearColor(0.5f, 0.8f, 1.0f);

	Camera camera = new Camera();
	camera.setWidth(1600);
	camera.setHeight(900);
	camera.setFov(45);
	
	camera.transform.position = vec3(0, 1, 2);
	camera.addComponent(new FPSRotation());

	RenderContext render = RenderContext();
	render.camera = camera;

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	//glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	
	// TODO: Minimize all this code to 15-25 lines + shaders + imports

	KeyboardState* state = Keyboard.getState();
	MouseState* mstate = Mouse.getState();

	Mouse.capture(cast(DesktopView)context.view);

	while(context.update())
	{
		state = Keyboard.getState();
		mstate = Mouse.getState();

		renderer.beginFrame();
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);
		
		camera.performUpdate(0);

		context.draw(render);

		renderer.endFrame();
		
		if (state.isKeyDown(SDLK_w)) camera.transform.position += vec3(cos(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x), -sin(-camera.transform.rotation.x), sin(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x)) * 0.1f;
		if (state.isKeyDown(SDLK_s)) camera.transform.position -= vec3(cos(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x), -sin(-camera.transform.rotation.x), sin(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x)) * 0.1f;
		if (state.isKeyDown(SDLK_a)) camera.transform.position -= vec3(cos(-camera.transform.rotation.y), 0, sin(-camera.transform.rotation.y)) * 0.1f;
		if (state.isKeyDown(SDLK_d)) camera.transform.position += vec3(cos(-camera.transform.rotation.y), 0, sin(-camera.transform.rotation.y)) * 0.1f;
		if (state.isKeyDown(SDLK_SPACE)) camera.transform.position += vec3(0, 1, 0) * 0.1f;
		if (state.isKeyDown(SDLK_LSHIFT)) camera.transform.position -= vec3(0, 1, 0) * 0.1f;
		if (state.isKeyDown(SDLK_ESCAPE)) break;
		//if (state.isKeyDown(SDLK_a)) camera.transform.position.z += 0.1f;
		//if (state.isKeyDown(SDLK_d)) camera.transform.position.z -= 0.1f;
		//camera.transform.rotation -= vec3(mstate.offset.y, mstate.offset.x, 0) * 0.005f;
	}

	context.stop();
}
