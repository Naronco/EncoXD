// Made for a 12h game compo

import EncoShared;
import EncoDesktop;
import EncoGL3;

import std.random;
import std.datetime;

class DragRotation : IComponent
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

	public override void preUpdate(double deltaTime)
	{
	}

	public override void update(double deltaTime)
	{
		mstate = Mouse.getState();
		cstate = Controller.getState(0);
		if (mstate.isButtonDown(0))
			object.transform.rotation -= vec3(mstate.offset.y, mstate.offset.x, 0) * deltaTime * 0.5;
		if (cstate.isConnected)
			object.transform.rotation -= vec3(cstate.getAxis(3), cstate.getAxis(2), 0) * deltaTime * 2;
		if (object.transform.rotation.x > 1.5707963f)
			object.transform.rotation.x = 1.5707963f;
		if (object.transform.rotation.x < -1.5707963f)
			object.transform.rotation.x = -1.5707963f;
	}

	private MouseState* mstate;
	private ControllerState* cstate;
	public GameObject object;
}

class GPSLayer : RenderLayer
{
	GLRenderTarget target;
	Material material;
	MeshObject gps;
	Mesh arrow, bg;
	ShaderProgram shader;
	GLTexture font;
	GameLayer game;

	public override void init(Scene scene)
	{
		ContentManager content = new ContentManager(new GLDevice(cast(GL3Renderer) scene.renderer));

		target = new GLRenderTarget();
		target.init(256, 256, false, scene.view);

		font = cast(GLTexture) content.loadTexture("res/tex/gpsfontinv.png");
		font.minFilter = TextureFilterMode.Nearest;
		font.magFilter = TextureFilterMode.Nearest;
		font.applyParameters();

		material = content.loadMaterial("res/materials/gps.json");
		material.textures[0] = target.color;
		shader = material.program;
		shader.registerUniforms(["clip", "color"]);
		shader.set("clip", vec4(0, 0, 1, 1));
		shader.set("color", vec4(1, 1, 1, 1));
		addGameObject(gps = new MeshObject(Mesh.loadFromObj("res/meshes.obj", 0)[1], material));

		arrow = new Mesh();
		arrow.addVertices([vec3(0, 1, 0), vec3(0.5f, 0, 0), vec3(1, 1, 0)]);
		arrow.addTexCoords([vec2(0, 0), vec2(0.5f, 1), vec2(1, 0)]);
		arrow.addNormals([vec3(0, 1, 0), vec3(0, 1, 0), vec3(0, 1, 0)]);
		arrow.addIndices([0, 1, 2]);
		arrow = scene.renderer.createMesh(arrow);
	}

	void apply(GameLayer game)
	{
		this.game = game;
		gps.transform.parent = &game.truck.transform;
	}

	override protected void draw2D(GUIRenderer renderer)
	{
		if (game is null)
			return;

		target.bind();
		renderer.resize(256, 256);
		renderer.renderRectangle(vec2(0, 0), vec2(256, 256), GLTexture.white, vec4(1, 0.95f, 0.85f, 1));

		renderer.renderMesh(arrow, vec2(128 - 40, 0), vec2(80, 300), GLTexture.white, vec4(0.9f, 0.7f, 0.5f, 1));
		renderer.renderMesh(arrow, vec2(128 - 25, 0), vec2(50, 300), GLTexture.white, vec4(1, 0.8f, 0.6f, 1));
		renderer.renderMesh(arrow, vec2(128 - 48 - 8, 8), vec2(96 + 16, 64 + 16), GLTexture.white, vec4(0.1f, 0.45f, 0.8f, 1));
		renderer.renderMesh(arrow, vec2(128 - 48, 16), vec2(96, 64), GLTexture.white, vec4(0.2f, 0.55f, 0.9f, 1));

		auto time = Clock.currTime();
		bool pm = false;
		ubyte hour = time.hour;
		if (hour > 12)
		{
			hour -= 12;
			pm = true;
		}

		renderer.renderRectangle(vec2(24 + 24 * 0, 256 - 24 - 48), vec2(24, 48), vec4(8 * (hour / 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 1, 256 - 24 - 48), vec2(24, 48), vec4(8 * (hour % 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 2, 256 - 24 - 48), vec2(24, 48), vec4(8 * 15 /* : */, 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 3, 256 - 24 - 48), vec2(24, 48), vec4(8 * (time.minute / 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 4, 256 - 24 - 48), vec2(24, 48), vec4(8 * (time.minute % 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 5, 256 - 24 - 48), vec2(24, 48), vec4(8 * (pm ? 10 : 11) /* P */, 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 6, 256 - 24 - 48), vec2(24, 48), vec4(8 * 13 /* M */, 0, 8, 8), font, vec4(0, 0, 0, 1));

		int km = 6000 - cast(int) round(game.distance * 0.00003472222f * 6000); // Results in 752 for 75.2km

		renderer.renderRectangle(vec2(24 + 24 * 0, 24), vec2(24, 48), vec4(8 * (km / 1000 % 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 1, 24), vec2(24, 48), vec4(8 * (km / 100 % 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 2, 24), vec2(24, 48), vec4(8 * (km / 10 % 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 3, 24), vec2(24, 48), vec4(8 * 14 /* . */, 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 4, 24), vec2(24, 48), vec4(8 * (km % 10), 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 5, 24), vec2(24, 48), vec4(8 * 12 /* K */, 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.renderRectangle(vec2(24 + 24 * 6, 24), vec2(24, 48), vec4(8 * 13 /* M */, 0, 8, 8), font, vec4(0, 0, 0, 1));
		renderer.resize(1600, 900);
		target.unbind();
	}
}

class GameLayer : RenderLayer
{
	MeshObject truck, wheel, wiper1, wiper2;
	MeshObject floor;
	Material floorMat, sky;
	float fade = 1;
	float ya = 0;
	float distance = 0;
	float waitTime = 60;
	float wipeTime = 0;
	bool wipe = false;
	bool goingBack = false;
	bool justStarted = true;
	float animationTime = 0;
	float skyTime = 0;
	Camera camera;
	bool firstFrame = true;
	GameWindow game;

	void reset()
	{
		fade = 1;
		ya = 0;
		distance = 0;
		waitTime = 60;
		wipeTime = 0;
		wipe = true;
		goingBack = false;
		justStarted = true;
		animationTime = 0;
		firstFrame = true;
	}

	public this(GameWindow game)
	{
		this.game = game;
	}

	public override void init(Scene scene)
	{
		ContentManager content = new ContentManager(new GLDevice(cast(GL3Renderer) scene.renderer));
		auto models = Mesh.loadFromObj("res/meshes.obj", 0);

		sky = content.loadMaterial("res/materials/timedskydome.json");
		sky.program.registerUniform("time");
		MeshObject skyobj;
		addGameObject(skyobj = new MeshObject(models[5], sky));
		skyobj.renderRelative = true;

		auto mat = content.loadMaterial("res/materials/truck.json");
		truck = new MeshObject(models[0], mat);
		GameObject parent = new GameObject();
		wheel = new MeshObject(models[3], mat);
		parent.addChild(wheel);
		parent.transform.position = vec3(0, 2.5f, -2.06f);
		parent.transform.rotation = vec3(-1.0f, 0, 0);
		truck.addChild(parent);
		truck.addChild(wiper1 = new MeshObject(models[4], mat));
		truck.addChild(wiper2 = new MeshObject(models[4], mat));
		wiper1.transform.position = vec3(-1.35f, 3.33f, -3.82f);
		wiper2.transform.position = vec3(1.50f, 3.33f, -3.82f);
		addGameObject(truck);
		floorMat = content.loadMaterial("res/materials/infinite.json");
		floorMat.program.registerUniforms(["time", "permTexture"]);
		floorMat.program.set("permTexture", 2);

		int[256] perm = [151, 160, 137, 91, 90, 15,
						 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
						 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
						 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
						 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
						 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196,
						 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123,
						 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
						 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
						 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228,
						 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
						 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
						 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180];

		int[3][16] grad3 = [[0, 1, 1], [0, 1, -1], [0, -1, 1], [0, -1, -1],
							[1, 0, 1], [1, 0, -1], [-1, 0, 1], [-1, 0, -1],
							[1, 1, 0], [1, -1, 0], [-1, 1, 0], [-1, -1, 0], // 12 cube edges
							[1, 0, -1], [-1, 0, -1], [0, -1, 1], [0, 1, 1]]; // 4 more to make 16

		ubyte[] pixels = new ubyte[256 * 256 * 4];
		for (int i = 0; i < 256; i++)
		{
			for (int j = 0; j < 256; j++)
			{
				int offset = (i * 256 + j) * 4;
				ubyte value = cast(ubyte) perm[(j + perm[i]) & 0xFF];
				pixels[offset] = cast(ubyte) (grad3[value & 0x0F][0] * 64 + 64); // Gradient x
				pixels[offset + 1] = cast(ubyte) (grad3[value & 0x0F][1] * 64 + 64); // Gradient y
				pixels[offset + 2] = cast(ubyte) (grad3[value & 0x0F][2] * 64 + 64); // Gradient z
				pixels[offset + 3] = cast(ubyte) value;               // Permuted index
			}
		}

		GLTexture permTex = new GLTexture();
		permTex.minFilter = TextureFilterMode.Nearest;
		permTex.magFilter = TextureFilterMode.Nearest;
		permTex.create(256, 256, pixels);

		floorMat.textures[2] = permTex;

		addGameObject(floor = new MeshObject(models[2], floorMat));
	}

	void apply(Camera camera)
	{
		this.camera = camera;
		truck.addChild(camera);
	}

	override protected void update(double deltaTime)
	{
		if (firstFrame)
		{
			fade = 0;
			firstFrame = false;
		}
		if (abs(truck.transform.position.x) > 11)
		{
			goingBack = true;
			wipe = false;
		}
		if (goingBack)
		{
			if (justStarted)
			{
				if (animationTime < 1)
				{
					distance += deltaTime * (1 - animationTime);
					// Slowly breaking
					animationTime += deltaTime;
				}
				else
				{
					animationTime = 0;
					justStarted = false;
				}
			}
			else
			{
				if (waitTime > 0)
				{
					waitTime -= deltaTime;
				}
				else
				{
					if (animationTime < 2)
					{
						animationTime += deltaTime;
						truck.transform.rotation.x = animationTime * 0.05f;
					}
					else if (animationTime < 3)
					{
						animationTime += deltaTime;
						distance -= deltaTime * (animationTime - 2);
						truck.transform.position.x *= 0.97f;
						truck.transform.rotation.x = 0.1f;
					}
					else
					{
						distance -= deltaTime;
						if (distance < 1)
						{
							fade = distance;
							if (fade < 0)
							{
								fade = 0;
								game.scene = game.menu;
								reset();
								return;
							}
						}
					}
				}
			}
		}
		else
		{
			if (fade < 1)
			{
				fade += deltaTime;

				if (fade > 1)
				{
					fade = 1;
				}
			}
			distance += deltaTime;
			if (distance > 28_800)
			{
				score++;
				if (score > 999)
					score = 999;
				game.scene = game.menu;
				reset();
				return;
			}
			truck.transform.position.x += (ya + 0.4f) * 0.1f;
			truck.transform.position.y = uniform(0, 0.007f);
		}
		if (Keyboard.getState().isKeyDown(Key.A))
			ya -= 0.05f;
		if (Keyboard.getState().isKeyDown(Key.D))
			ya += 0.05f;
		if (wipe || abs(wipeTime - 4.71238898038f) > 0.05f)
			wipeTime += deltaTime * 1.1f;
		if (wipeTime > 3.1415926f * 2)
			wipeTime -= 3.1415926f * 2;
		ya *= 0.95f;
		floorMat.program.bind();
		floorMat.program.set("time", distance * 2);
		wheel.transform.rotation = vec3(0, ya, 0);
		camera.transform.position.x = truck.transform.position.x + 0.02141f;
		wiper1.transform.rotation.z = -(sin(wipeTime) + 1);
		wiper2.transform.rotation.z = -(sin(wipeTime) + 1);
		skyTime = cast(float) ((Clock.currStdTime() % 864_000_000_000) * 1.1574074e-12);
		sky.program.bind();
		sky.program.set("time", skyTime);
	}
}

class GameScene : Scene
{
	public GameLayer layer;
	public GPSLayer gps;
	GameWindow window;

	public this(GameWindow window)
	{
		this.window = window;
	}

	public override void init()
	{
		addLayer(layer = new GameLayer(window));
		addLayer(gps = new GPSLayer());
	}
}

class MenuScene : Scene
{
	bool pervLMB;
	GameWindow game;
	GLTexture font;

	public this(GameWindow game)
	{
		this.game = game;
	}

	override public void init()
	{
		PictureControl banner = new PictureControl();
		banner.size(0, -20, 200, 40);
		banner.alignment = Alignment.MiddleCenter;
		auto tex = new GLTexture();
		tex.fromBitmap(Bitmap.load("res/tex/banner.png"));
		banner.texture = tex;
		addChild(banner);

		PictureControl play = new PictureControl();
		play.size(0, 20, 100, 30);
		play.alignment = Alignment.MiddleCenter;
		auto tex2 = new GLTexture();
		tex2.fromBitmap(Bitmap.load("res/tex/play.png"));
		play.texture = tex2;
		addChild(play);

		PictureControl score = new PictureControl();
		score.size(-50, 60, 100, 30);
		score.alignment = Alignment.MiddleCenter;
		auto tex3 = new GLTexture();
		tex3.fromBitmap(Bitmap.load("res/tex/score.png"));
		score.texture = tex3;
		addChild(score);

		font = new GLTexture();
		font.minFilter = TextureFilterMode.Nearest;
		font.magFilter = TextureFilterMode.Nearest;
		font.fromBitmap(Bitmap.load("res/tex/gpsfont.png"));
	}

	override protected void draw2D(GUIRenderer gui)
	{
		gui.renderRectangle(vec2(gui.size.x / 2 + 24 * 0, gui.size.y / 2 + 50), vec2(24, 24), vec4(8 * (score / 100 % 10), 0, 8, 8), font, vec4(1, 1, 1, 1));
		gui.renderRectangle(vec2(gui.size.x / 2 + 24 * 1, gui.size.y / 2 + 50), vec2(24, 24), vec4(8 * (score / 10 % 10), 0, 8, 8), font, vec4(1, 1, 1, 1));
		gui.renderRectangle(vec2(gui.size.x / 2 + 24 * 2, gui.size.y / 2 + 50), vec2(24, 24), vec4(8 * (score % 10), 0, 8, 8), font, vec4(1, 1, 1, 1));
	}

	override protected void update(double deltaTime)
	{
		if (pervLMB && !Mouse.getState().isButtonDown(0))
		{
			game.scene = game.game;
		}
		pervLMB = Mouse.getState().isButtonDown(0);
	}
}

class GameWindow : DesktopView
{
	RenderContext context;
	GameScene game;
	MenuScene menu;
	GLRenderTarget target;
	GLShaderProgram post;
	GLTexture fog;
	Mesh plane;
	Camera camera;

	public this()
	{
		scene = game = new GameScene(this);
	}

	public void init()
	{
		renderer.setClearColor(0, 0, 0);

		game.gps.apply(game.layer);

		camera = new Camera();
		camera.nearClip = 0.1f;
		camera.farClip = 600.0f;
		camera.width = width;
		camera.height = height;
		camera.fov = 70;
		camera.transform.position = vec3(0.02141f, 4.39816f, 0.75f);

		camera.addComponent(new DragRotation());

		context = RenderContext(camera, vec3(1, 0.5, 0.3));

		game.layer.apply(camera);

		target = new GLRenderTarget();
		target.init(width, height, true, this);

		post = cast(GLShaderProgram) GLShaderProgram.fromVertexFragmentFiles(cast(GL3Renderer) renderer, "res/shaders/post.vert", "res/shaders/fog.frag");
		post.registerUniforms(["slot0", "slot1", "slot2", "slot3", "dist", "time", "fade"]);
		post.set("slot0", 0);
		post.set("slot1", 1);
		post.set("slot2", 2);
		post.set("slot3", 3);
		post.set("dist", 1.0f);

		fog = new GLTexture();
		fog.fromBitmap(Bitmap.load("res/tex/timedfog.png"));

		plane = renderer.createMesh(MeshUtils.createPlane());

		scene = menu = new MenuScene(this);
	}

	override protected void onDraw()
	{
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);

		target.bind();

		draw3D(context);

		renderer.gui.begin();

		draw2D();

		renderer.gui.end();

		target.unbind();

		post.bind();

		target.color.bind(0);
		target.depth.bind(1);
		game.layer.sky.textures[0].bind(2);
		fog.bind(3);

		post.set("fade", game.layer.fade);
		post.set("time", game.layer.skyTime);

		renderer.renderMesh(plane);
	}

	override protected void onUpdate(double delta)
	{
		update(delta);
	}
}

uint score = 0;

void main()
{
	EncoContext.create([DynamicLibrary.SDL2, DynamicLibrary.SDL2Image, DynamicLibrary.Assimp]);

	GameWindow window = new GameWindow();
	EncoContext.instance.addView!GL3Renderer(window);
	EncoContext.instance.importSettings(import ("demo.json"));
	EncoContext.instance.start();
	scope (exit) EncoContext.instance.stop();

	window.init();

	while (EncoContext.instance.update())
	{
		EncoContext.instance.draw();
		EncoContext.instance.endUpdate();
	}
}
