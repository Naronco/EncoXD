module GameScene;

import EncoShared;
import EncoDesktop;
import EncoGL3;

class Game3DLayer : RenderLayer
{
	AnimatedProperty!float carY;
	GameObject carObj, carGlassObj;

	public override void init(Scene scene)
	{
		auto meshes = Mesh.loadFromObj("meshes/yard.obj", 0);
		
		addGameObject(new MeshObject(meshes[0], GLMaterial.load(scene.renderer, "materials/grass.json")));
		addGameObject(new MeshObject(meshes[1], GLMaterial.load(scene.renderer, "materials/brick.json")));
		addGameObject(new MeshObject(meshes[2], GLMaterial.load(scene.renderer, "materials/yard_decoration.json")));
		addGameObject(new MeshObject(meshes[3], GLMaterial.load(scene.renderer, "materials/tree.json")));

		auto clouds = Mesh.loadFromObj("meshes/cloudPlane.obj", 0)[0];
		MeshObject cloudsObj = new MeshObject(clouds, GLMaterial.load(scene.renderer, "materials/clouds.json"));
		cloudsObj.transform.scale = vec3(600, 400, 600);
		cloudsObj.renderRelative = true;
		addGameObject(cloudsObj);

		MeshObject cloudsObj2 = new MeshObject(clouds, GLMaterial.load(scene.renderer, "materials/clouds2.json"));
		cloudsObj2.transform.scale = vec3(600, 300, 600);
		cloudsObj2.renderRelative = true;
		addGameObject(cloudsObj2);
		
		
		carY = new AnimatedProperty!float(0.0f);
		carY.easingType = "quadratic";
		carY.value = 5.0f;
		carY.length = 3000;

		auto car = Mesh.loadFromObj("meshes/car.obj", 0);
		carGlassObj = addGameObject(new MeshObject(car[0], GLMaterial.load(scene.renderer, "materials/glass.json")));
		carObj = addGameObject(new MeshObject(car[1], GLMaterial.load(scene.renderer, "materials/car.json")));
	}

	override protected void update(f64 deltaTime)
	{
		carY.update(deltaTime);
	}
	
	override protected void preDraw(RenderContext context, IRenderer renderer)
	{
		carObj.transform.position.y = cast(float)carY;
		carGlassObj.transform.position.y = cast(float)carY;
	}
}

const enum BORDER_SIZE = 100;

class UILayer : RenderLayer
{
	float t = 0;
	Color c = Color(0, 0, 0);
	DynamicColorControl left, right, top, bottom;

	public override void init(Scene scene)
	{
		addSolid(8, scene.view.height - 110, 69, 102, Color.fromHex(0x37474F));
		for(int i = 0; i < 5; i++)
			addSolid(10, scene.view.height - 108 + i * 20, 65, 18, Color.fromHex(0x80CBC4));

		c.fromHSL(0.0, 1.0, 0.5);


		left = new DynamicColorControl(c);
		left.width = BORDER_SIZE;
		left.height = scene.view.height >> 2;
		left.alignment = Alignment.MiddleLeft;

		right = new DynamicColorControl(c);
		right.width = BORDER_SIZE;
		right.height = scene.view.height >> 2;
		right.alignment = Alignment.MiddleRight;

		top = new DynamicColorControl(c);
		top.width = scene.view.width >> 2;
		top.height = BORDER_SIZE;
		top.alignment = Alignment.TopCenter;

		bottom = new DynamicColorControl(c);
		bottom.width = scene.view.width >> 2;
		bottom.height = BORDER_SIZE;
		bottom.alignment = Alignment.BottomCenter;
		
		addGameObject(left);
		addGameObject(right);
		addGameObject(top);
		addGameObject(bottom);
	}

	private void addSolid(float x, float y, float width, float height, Color color)
	{
		PictureControl pic = PictureControl.fromColor!GLTexture(color);
		pic.x = x;
		pic.y = y;
		pic.width = width;
		pic.height = height;
		addGameObject(pic);
	}

	private void addImage(float x, float y, float width, float height, ITexture tex)
	{
		PictureControl pic = new PictureControl(tex);
		pic.x = x;
		pic.y = y;
		pic.width = width;
		pic.height = height;
		addGameObject(pic);
	}

	override protected void update(f64 deltaTime)
	{
		t += deltaTime;
		c.fromHSL(t % 1, 1.0, 0.5);
		left.color = c;
		right.color = c;
		top.color = c;
		bottom.color = c;
	}
}

class DebugLayer : RenderLayer
{
	public override void init(Scene scene)
	{
		string os = "unknown";
		version(Windows) addVersion(os = "win");
		version(linux) addVersion(os = "lin");
		version(OSX) addVersion(os = "osx");
		version(Android) addVersion(os = "android");

		Font font = new Font("fonts/Roboto/Roboto-Regular.ttf", 16);
		string compiler = "Unknown Compiler";
		version(DigitalMars) compiler = "DMD";
		version(GNU) compiler = "GDC";
		version(LDC) compiler = "LDC";
		version(SDC) compiler = "SDC";
		PictureControl fnt = new PictureControl(font.render!GLTexture("EncoXD " ~ ENCO_VERSION ~ " (" ~ to!string(ENCO_VERSION_ID) ~ ")\nCompiler: " ~ compiler ~ "\nCompiler-Platform: " ~ os, Color.White, 250));
		fnt.x = 20;
		fnt.y = 60;
		addGameObject(fnt);
	}

	public void addVersion(string ver)
	{
		PictureControl verPic = new PictureControl(GLTexturePool.load("tex/" ~ ver ~ ".png"));
		verPic.x = 20;
		verPic.y = 20;
		verPic.width = 200;
		verPic.height = 100;
		addGameObject(verPic);
	}
}

class GameScene : Scene
{
	public Game3DLayer game3DLayer;

	public override void init()
	{
		addLayer(game3DLayer = new Game3DLayer());
		addLayer(new UILayer());
		addLayer(new DebugLayer());
	}
}